$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..')

require 'orb/provider'
require 'orb/media'

class NetflixRokuProvider < ORB::Media::MediaProvider
  def initialize
    super :netflix
  end
  
  def play_item item, device
    super
  
    raw = open("https://flixable.com/?s=#{item}").read

    if a=raw.scan(/\/title\/([0-9]+)\//)[0]
      id = a[0]
      ## Not for netflix
      # device.roku.request "/launch/12?contentID=#{id}"
      
      device.roku.find_then_play item, provider: "12"
    end
  end
  
  def pause
    device.key_press :play
  end
  
  def play
    device.key_press :play
  end
end
