$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..')

require 'orb/providers/chromecast/cc-base-provider'

class CCYouTubeProvider < CCBaseProvider
  def initialize
    super :youtube
  end
  
  def play_item item, device  
    super
      
    #uri = "https://www.youtube.com/results?search_query=#{item.gsub(" ", "+")}"
    #result = open(uri).read
    #songs = result.scan(/\/watch\?.*?v\=(.*?)\"/).map do |u| "http://youtube.com#{u[0].split("&")[0]}" end
    
    #if songs and song = songs.shift
      device.cc.cast "https://www.youtube.com/results?search_query=#{item.gsub(" ", "+")}" #"\"#{song}\""
    #end
  end
end
