module Migrate
  class << self


    def migrate_all_playlists
      puts 'Locating unmigrated playlists...'
      playlists = unmigrated_playlists

      playlists.each_with_index do |playlist, index|
        puts "#{index}: migrating #{playlist.id}"
        migrate_playlist(playlists)
        puts "#{index}: #{playlist.id} migrated"
      end
    end

    def migrate_playlist(playlist)
      preexisting_casebook = Content::Casebook.where(playlist_id: playlist.id).where(created_at: playlist.created_at)

      if preexisting_casebook.present?
        puts "Playlist #{playlist.id} is a duplicate of Casebook #{preexisting_casebook.id}"
      else
        puts "Migrating playlist #{playlist.id}"
        # create casebook for playlist
        ActiveRecord::Base.transaction do
          casebook = Content::Casebook.create created_at: playlist.created_at,
            title: playlist.name, # + " [Playlist \##{playlist.id}]",
            headnote: sanitize(playlist.description),
            public: playlist.public,
            owners: [playlist.user],
            playlist_id: playlist.id,
            root_user_id: playlist.root.user_id

          migrate_items(playlist.playlist_items, path: [], casebook: casebook)
          casebook
        end
      end
    end

    # recursive call to migrate section contents
    def migrate_items(playlist_items, path:, casebook: )
      playlist_items.order(:position).each_with_index do |item, index|
        if item.actual_object_type.in? %w{Playlist Collage Media}
          item.actual_object_type = "Migrate::#{item.actual_object_type}"
        end
        object = item.actual_object
        ordinals = path + [index + 1]
        if object.is_a? Migrate::Playlist
          Content::Section.create casebook: casebook,
            title: object.name,
            headnote: sanitize(object.description),
            ordinals: ordinals
          migrate_items object.playlist_items, path: ordinals, casebook: casebook
        else
          imported_resource = object

          if imported_resource.nil?
            imported_resource = Default.create name: "[Missing #{item.actual_object_type} \##{item.actual_object_id}]",
              url: "https://h2o.law.harvard.edu/#{item.actual_object_type.downcase}s/#{item.actual_object_id}"
          end

          if imported_resource.is_a? Migrate::Collage
            if imported_resource.annotatable_type.in? %w{Playlist Collage Media}
              imported_resource.annotatable_type = "Migrate::#{object.annotatable_type}"
            end
            imported_resource = imported_resource.annotatable

            if imported_resource.nil?
              imported_resource = Default.create name: "[Missing annotated #{object.annotatable_type} \##{object.annotatable_id}]",
                url: "https://h2o.law.harvard.edu/collages/#{object_id}"
            end
          end

          if imported_resource.is_a? Migrate::Media
            imported_resource = Default.create name: imported_resource.name,
              description: imported_resource.description,
              url: imported_resource.content,
              user_id: imported_resource.user_id
          end

          resource = Content::Resource.create casebook: casebook,
            resource: imported_resource,
            ordinals: ordinals

          if object.is_a? Migrate::Collage
            migrate_annotations(object, resource)
          end

          resource
        end
      end
    end

    # Source annotations are located by xpaths, which can't be ordered for caching.
    # Target nodes are located by the index of the paragraph, consistent with WordML etc.
    # This finds the appropriate paragraph for the annotation's xpath.
    def migrate_annotations(collage, resource)
      return unless resource.resource.class.in? [Case, TextBlock]

      nodes = Nokogiri::HTML(resource.resource.content) {|config| config.noblanks}
      idx = 0
      nodes.traverse do |node|
        next if node.text?
        node['idx'] = idx
        idx += 1
      end
      nodes = resource.preprocess_nodes nodes

      collage.annotations.each do |annotation|
        content = nil

        if annotation.hidden
          if annotation.annotation.present?
            content = annotation.annotation
            kind = 'replace'
          else
            kind = 'elide'
          end
        elsif annotation.link.present?
          content = annotation.link
          kind = 'link'
        elsif annotation.annotation.present?
          content = annotation.annotation
          kind = 'note'
        elsif annotation.highlight_only.present?
          content = annotation.highlight_only
          kind = 'highlight'
        else
          # puts "Need help migrating annotation \##{annotation.id}: Collage \##{annotation.collage.id} #{annotation.xpath_start} -> #{annotation.xpath_end}"
          kind 'highlight'
        end

        content_annotation = Content::Annotation.new resource: resource,
          kind: kind,
          content: "#{content} [\##{annotation.id}]"
        if annotation.xpath_start.present? && annotation.xpath_end.present?
          start_p, start_offset = locate_p annotation.xpath_start, annotation.start_offset, nodes, document
          end_p, end_offset = locate_p annotation.xpath_end, annotation.end_offset, nodes, document
          unless (start_p && end_p && start_offset && end_offset)
            next
          end
          if start_p > end_p
            _start_p = end_p
            end_p = start_p
            start_p = _start_p
          end
          content_annotation.assign_attributes start_p: start_p,
            end_p: end_p,
            start_offset: start_offset,
            end_offset: end_offset
        else
          puts "no xpath for annotation \#", annotation.id
          return
        end
        content_annotation.save!
      end
    end

    def locate_p xpath, offset, nodes, document
      # xpath.gsub! %r{/div\[\d+\]}, ''

      unless xpath.present?
        puts "no xpath"
        # puts "Got a bad p for \##{annotation.id}: Collage \##{annotation.collage.id} at #{annotation.xpath_start} -> #{annotation.xpath_end}"

        return
      end
      target_node = document.xpath('//body' + xpath).first
      unless target_node
        unless xpath.match %r{a\[2\]$}
          puts "no target node: #{xpath}"
          # puts "Got a bad p for \##{annotation.id}: Collage \##{annotation.collage.id} at #{annotation.xpath_start} -> #{annotation.xpath_end}"

        end
        return
      end
      target_p = target_node.xpath('./ancestor-or-self::node()[parent::body]').first
      unless target_p
        puts "no target p for #{xpath}"
        # puts "Got a bad p for \##{annotation.id}: Collage \##{annotation.collage.id} at #{annotation.xpath_start} -> #{annotation.xpath_end}"
        return
      end
      p_idx = nodes.find_index {|node| node['idx'] == target_p['idx']}
      if target_p == target_node
        return p_idx, offset
      end
      target_p.traverse do |node|
        next unless node.text?

        if node.parent == target_node
          break
        end
        if node.text?
          offset += node.text.length
        end
      end
      return p_idx, offset
    end

    # associate original with migrated by creation date
    def unmigrated_playlists
      root_playlists.reject {|playlist| Content::Casebook.find_by_playlist_id(playlist.id) }
    end

    def sanitize html
      ActionView::Base.full_sanitizer.sanitize html
    end

    # root playlists do not occur in playlistitems
    def root_playlists
      Migrate::Playlist.all.reject {|playlist| Migrate::PlaylistItem.where(actual_object_type: 'Playlist').find_by_actual_object_id playlist.id}
      .reject {|playlist| playlist.playlist_items.count == 0}
    end

    def remigrate_annotations
      @@collages = []
      @@collages_by_playlist = {}
      playlist_ids = [66, 603, 633, 711, 986, 1324, 1369, 1510, 1844, 1862, 1889, 1923, 1995, 3762, 5094, 5143, 5555, 5804, 5866, 5876, 7072, 7337, 7384, 7390, 7399, 7446, 8624, 8770, 9141, 9156, 9157, 9267, 9364, 9504, 9623, 10007, 10033, 10065, 10236, 10237, 10572, 10609, 11114, 11492, 11800, 12489, 12716, 12826, 12864, 12865, 12922, 13023, 13034, 13086, 14454, 17803, 19763, 20336, 20370, 20406, 20443, 20493, 20630, 20861, 21225, 21529, 21898, 21913, 22180, 22188, 22189, 22235, 22269, 22363, 22368, 22568, 24353, 24419, 24704, 24739, 25022, 25421, 25606, 25698, 25965, 26039, 26057, 26074, 26143, 26147, 26221, 26241, 26271, 26372, 26401, 26452, 26559, 27297, 27438, 27790, 27819, 27845, 28015, 28148, 28286, 50966, 51028, 51291, 51531, 51575, 51676, 51703, 51759, 51760, 51770, 51792, 51938, 51971, 52383, 52511, 52719]
      playlists = Migrate::Playlist.find(playlist_ids)

      playlists.each do |playlist|
        @@original_playlist = playlist
        get_collages_from_playlist(playlist)
      end

      puts @@collages_by_playlist.inspect


      # playlist_ids.each do |playlist_id|
      #   casebook = Content::Casebook.find_by_playlist_id(playlist_id)
      #   collages = @@collages_by_playlist[playlist_id]

      #   collages.each do |collage|
      #     resource = casebook.resources.find_by_resource_id(collage.annotatable_id)
      #     Migrate.migrate_annotations(collage, resource)
      #   end
      # end
    end

    def get_collages_from_playlist(playlist)
      playlist_items = playlist.playlist_items

      playlist_items.each do |item|
        if item.actual_object_type == 'Playlist'
          if Migrate::Playlist.where(id: item.actual_object_id).any? ## broken links to playlists
            next_playlist = Migrate::Playlist.find(item.actual_object_id)
            get_collages_from_playlist(next_playlist)
          end 
        elsif item.actual_object_type == 'Collage'
          if Migrate::Collage.where(id: item.actual_object_id).any?
            collage = Migrate::Collage.find(item.actual_object_id)
            if @@collages_by_playlist[@@original_playlist.id].nil?
              @@collages_by_playlist[@@original_playlist.id] = [collage]
            else
              @@collages_by_playlist[@@original_playlist.id].push(collage)
            end
          end
        end
      end
    end

  end
end
