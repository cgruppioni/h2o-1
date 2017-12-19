@collages = []
playlist = Playlist object

def get_collages_from_playlist(playlist)
  playlist_items = playlist.playlist_items

  playlist_items.each do |item|
    if item.object_type = 'Playlist'
      next_playlist = Migrate::Playlist.find(item.playlist_id)
      get_collages_from_playlist(next_playlist) 
    elsif item.object_type = 'Collage'
      collages << playlist_item
    end
  end
end