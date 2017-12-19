--------------------

# resource = Content::Casebook.find(4376).resources.where(ordinals: [5, 2]).first

# collage = Migrate::Collage.where(annotatable_id: resource.resource_id).first

---------------------

Remigrate all case annotations
---------------------
# 1 \\ fill in all annotation fields with collage id
# annotations_with_empty_relationship_field = Migrate::Annotation.where(collage_id: nil).where.not(annotated_item_id: nil)

# annotations_with_empty_relationship_field.each do |annotation|
#   annotation.update(collage_id: annotation.annotated_item_id)
# end


# 2 \\ Content::Annotation.destroy_all


# 3 \\ reload database && add script to migrate.db

# 4 \\ get all collages that have annotations ( need to reimport all )
# collages_with_annotations = Migrate::Collage.includes(:annotations).where(annotations: { id: nil })
# collages_with_annotations =

# Migrate::Collage.includes(:annotations).references(:annotations).where(annotations: { id: nil })


Just doing all collages

# 5\\ find collage & content::resource objects that match and then migrate them. ## AFAIK can't find playlist from collage object alone and need to drill up to find it (find collage's playlist item and drill up until get collage playlist id to find content casebook and matching resource (no other defining way to see relationship besides looping i think) and migrate data

collages = Migrate::Collage.all.last(10)
collages = Migrate::Collage.all

Migrate.remigrate_annotations

collages.each do |collage|
  playlist_id = Migrate.get_collage_playlist_id(collage.id)
  if casebook = Content::Casebook.find_by_playlist_id(playlist_id)
    resource = casebook.resources.find_by_resource_id(collage.annotatable_id)
    puts "Migrating annotations..."
    Migrate.migrate_annotations(collage, resource)
  else
    puts "Casebook with playlist id #{playlist_id} not found"
  end
end

# put in migrate.rb
def get_collage_playlist_id(collage_id)
  item_id = collage_id

  until Migrate::PlaylistItem.find_by_actual_object_id(item_id).blank?
    playlist_item = Migrate::PlaylistItem.find_by_actual_object_id(item_id)
    item_id = playlist_item.playlist_id
  end

  item_id
end


def get_collages_from_playlist(playlist)
  playlist.playlist_items.each do |item|


    if item.actual_object_type == 'playlist'
      playlist = Migrate::Playlist.find(item.actual_object_id)
      get_collages_from_playlist(playlist)
    elsif item.actual_object_type == 'collage'
      collages << item
    end
end


# playlist_ids = [66, 603, 633, 711, 986, 1324, 1369]

# Content::Casebook.where('playlist_id NOT IN ?', playlist_ids)
*********

    def get_collage_playlist_id(collage_id)
      puts "get_collage_playlist_id(#{collage_id})"
      item_id = collage_id

      until Migrate::PlaylistItem.find_by_actual_object_id(item_id).blank?
puts "IN LOOP #{item_id}"
playlist_item = Migrate::PlaylistItem.find_by_actual_object_id(item_id)
        item_id = playlist_item.playlist_id
      end
      puts "final item id: #{item_id}"
      item_id
    end

   def remigrate_annotations
puts 'hi'

     Migrate::Collage.all.limit(5) do |collage|
      puts '**********************'
      puts "Collage # #{collage.id}"
      playlist_id = Migrate.get_collage_playlist_id(collage.id)

      if casebook = Content::Casebook.find_by_playlist_id(playlist_id)
          resource = casebook.resources.find_by_resource_id(collage.annotatable_id)
          puts "Migrating annotations..."
          Migrate.migrate_annotations(collage, resource)
      else
          puts 'Casebook with playlist id #{playlist_id} not found'
      end
   end
end