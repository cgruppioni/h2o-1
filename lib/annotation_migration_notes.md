--------------------

resource = Content::Casebook.find(4376).resources.where(ordinals: [5, 2]).first

collage = Migrate::Collage.where(annotatable_id: resource.resource_id).first

---------------------
Remigrate all case annotations
---------------------
1 // Content::Annotations.destroy_all

2 // fill in all annotation fields with collage id 
annotations_with_empty_relationship_field = Migrate::Annotation.where(collage_id: nil).where.not(annotated_item_id: nil)

annotations_with_empty_relationship_field.each do |annotation|
  annotation.update(collage_id: annotation.annotated_item_id)
end

3 // reload database 

4 // get collage playlist id to find content casebook and matching resource (no other defining way to see relationship besides looping i think) and migrate data 
collages_with_annotations = Migrate::Collage.includes(:annotations).where.not(annotations: { id: nil })

collages_with_annotations.each do |collage|
  get_collage_playlist_id(collage)
  casebook = Content::Casebook.find_by_playlist_id(playlist_id)
  resource = casebook.resources.find_by_resource_id(collage.annotatable_id) // too broud to do this for all casebooks 

  Migrate.migrate_annotations(collage, resource)
end

def get_collage_playlist_id(collage) // probably doesn't work
  object_id = collage.id

  until Migrate::PlaylistItem.find_by_actual_object_id(object_id).blank?
    Migrate::PlaylistItem.find_by_actual_object_id(object.id) // loop until you get to the very top
  end
end



