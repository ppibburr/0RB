$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..')

require 'orb/provider'
require 'orb/media'

require 'orb/providers/android/netflix'

class NetflixAndroidProvider < ORB::Media::MediaProvider
  def initialize
    super :netflix
  end
  
  DWELL = 5.333
  def play_item item, device
    super
  
    raw = open("https://flixable.com/?s=#{item}").read

    if a=raw.scan(/\/title\/([0-9]+)\//)[0]
      id = a[0]
      device.shell "am start -n com.netflix.mediaclient/.ui.launch.UIWebViewActivity -a android.intent.action.VIEW -d https://www.netflix.com/title/#{id}/"
      
      sleep DWELL
      
      device.key_press :ok
    end
  end
end
