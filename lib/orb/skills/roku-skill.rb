$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'
require 'orb/devices/roku'

require 'orb/providers/roku/netflix'
require 'orb/providers/roku/youtube'

class RokuSkill < ORB::DeviceSkill
  class RawDevice
    include ORB::DeviceSkill::RawDevice
    include ORB::Media::MediaDevice

    attr_accessor :ip, :config
    def initialize config
      @ip     = config['ip']
      @config = config
      
      roku(:ip=>ip)
    end

    def roku(*opts)
      return @roku if @roku and opts.empty?
      
      3.times do
        break if @roku = Roku::Device.find(*opts)
      end
      
      p @roku.location
      
      fail "No Roku" unless @roku
      
      @roku
    end
    
    def key_press key
      key = key.to_sym

      if Roku::Device::DIRECT_KEYS.index key
        roku.send key
      else
        roku.press(key)
      end
    end
    
    REPEAT_DELAY = 0.11
    
    def repeat_key_press key, times
      key = key.to_sym
      
      if Roku::Device::DIRECT_KEYS.index key
        roku.send key, times
      else
        times.times do
          roku.press(key)
          sleep REPEAT_DELAY
        end
      end
    end
    
    def ui_key key
    p :KEY,key
      key = :select if key.to_s.downcase.to_sym == :enter
    p key
      super key
    end
    
    def set_power_state state
      key_press :home
      #roku.power_on
    end
  
    def toggle
      set_power_state 1
    end
    
    def on?
      roku.boot_info[:power_mode] == "PowerOn"
    end
    
    def off?
      roku.boot_info[:power_mode] != "PowerOn"
    end
    
    def on
      toggle
    end
    
    def off
      toggle
    end
    
    def input text
    
    end    
  end
  
  def initialize config={}
    super config, RawDevice, config
  end
  
  def render app=nil
    app.content_type "text/plain"
  
    raw.roku.boot_info.inspect
  end
end
