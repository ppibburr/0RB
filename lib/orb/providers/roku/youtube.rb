$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..')

require 'orb/provider'
require 'orb/media'

require 'orb/providers/roku/youtube'

class YouTubeRokuProvider < ORB::Media::MediaProvider
  def initialize
    super :youtube, ['you to', 'you do', 'you tube']
  end
  
  def play_item item, device  
    super
      
    uri = "https://www.youtube.com/results?search_query=#{item.gsub(" ", "+")}"
    result = open(uri).read
    songs = result.scan(/\/watch\?.*?v\=(.*?)\"/).map do |u| u[0].split("&")[0] end
    
    if songs and song = songs[0]
      device.roku.request "/launch/837?contentID=#{song}"
    end
  end
  
  def pause
    device.key_press :pause
  end
  
  def play
    device.key_press :play
  end
  
  alias :resume :play
end
