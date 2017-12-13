
Attach missing annotations  - relationship wasn't functional in a lot of playlists (collage.annotations) because collage_id wasn't filled in 
-----------------

collage_ids = []

unmigrated_annotations.each do |annotation|
  annotation.update(collage_id: annotation.annotated_item_id)
  collage_ids << annotation.annotated_item_id
end

collage_ids = collage_ids.uniq

collage_ids.each do |collage_id|
  collage = Migrate::Collage.find(collage_id)
  resource = Content::Resource.where(resource_id: collage.annotatable_id).first
  Migrate.migrate_annotations(collage, resource)
end

--------------------
casebook = Content::Casebook.find(4376)

resource = Content::Casebook.find(4376).resources.where(ordinals: [5, 2]).first

collage = Migrate::Collage.where(annotatable_id: resource.resource_id).first

collage.annotations.count

resource.annotations.where(kind: 'elide')

