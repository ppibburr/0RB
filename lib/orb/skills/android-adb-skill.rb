$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'
require 'orb/devices/adb'

require 'orb/providers/android/netflix'
require 'orb/providers/android/youtube'

class AndroidADBSkill < ORB::DeviceSkill
  def initialize config={}
    super config, ADBDevice, config['name'], config['ip']
  end
end

class AndroidTVSkill < AndroidADBSkill
  require 'orb/devices/chromecast'
  require 'orb/providers/chromecast/cc-base-provider'
  require 'orb/providers/chromecast/cc-youtube-provider'
    
  include ChromeCast::RawChromeCast
  
  def initialize *o
    super *o
  
    class << raw
      attr_accessor :cc
    end
    
    raw.cc=self
  
    def raw.find_provider name, match
      if match and match[1]=~/^cast /
        name = "cc#{name}"
      end
    
      super name  
    end  
  end
end
