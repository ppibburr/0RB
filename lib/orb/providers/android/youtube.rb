$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..')

require 'orb/provider'
require 'orb/media'

class YouTubeAndroidProvider < ORB::Media::MediaProvider
  def initialize
    super :youtube
  end
  
  def play_item item, device  
    super
      
    uri = "https://www.youtube.com/results?search_query=#{item.gsub(" ", "+")}"
    result = open(uri).read
    songs = result.scan(/(\/watch\?.*?v\=.*?)\&amp\;/).map do |u| "http://youtube.com#{u[0]}" end
    
    if songs and song = songs[0]
      device.shell "am start -a android.intent.action.VIEW -d \"#{song}\""
    end
  end
  
  def pause
    device.key_press :pause
  end
end