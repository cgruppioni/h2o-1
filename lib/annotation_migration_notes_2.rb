Attempt 2

playlist_ids = [66, 603, 633, 711, 986, 1324, 1369, 1510, 1844, 1862, 1889, 1923, 1995, 3762, 5094, 5143, 5555, 5804, 5866, 5876, 7072, 7337, 7384, 7390, 7399, 7446, 8624, 8770, 9141, 9156, 9157, 9267, 9364, 9504, 9623, 10007, 10033, 10065, 10236, 10237, 10572, 10609, 11114, 11492, 11800, 12489, 12716, 12826, 12864, 12865, 12922, 13023, 13034, 13086, 14454, 17803, 19763, 20336, 20370, 20406, 20443, 20493, 20630, 20861, 21225, 21529, 21898, 21913, 22180, 22188, 22189, 22235, 22269, 22363, 22368, 22568, 24353, 24419, 24704, 24739, 25022, 25421, 25606, 25698, 25965, 26039, 26057, 26074, 26143, 26147, 26221, 26241, 26271, 26372, 26401, 26452, 26559, 27297, 27438, 27790, 27819, 27845, 28015, 28148, 28286, 50966, 51028, 51291, 51531, 51575, 51676, 51703, 51759, 51760, 51770, 51792, 51938, 51971, 52383, 52511, 52719]

playlists = Migrate::Playlist.find(playlist_ids)

playlists.each do |playlist|
  collages = get_collages_from_playlist(playlist)

def initialize
  @collages = []
end

def get_collages_from_playlist(playlist)
  playlist.playlist_items.each do |item|
    if item.actual_object_type == 'playlist'
      playlist = Migrate::Playlist.find(item.actual_object_id)
      self.get_collages_from_playlist(playlist)
    elsif item.actual_object_type == 'collage'
      self.collages << item
    end
  end
end

playlist = Migrate::Playlist.find(711)
Migrate.get_collages_from_playlist(playlist)
Migrate.get_collages

def get_collages_from_playlist(playlist)
  item = playlist.playlist_items.first
if item.actual_object_type == 'playlist'
playlist = Migrate::Playlist.find(item.actual_object_id)
    elsif item.actual_object_type == 'collage'
      collages << item
    end
  end


  playlist.playlist_items.each do |item|
    if item.actual_object_type == 'playlist'
      playlist = Migrate::Playlist.find(item.actual_object_id)
      self.get_collages_from_playlist(playlist)
    elsif item.actual_object_type == 'collage'
      self.collages << item
    end
  end
end
