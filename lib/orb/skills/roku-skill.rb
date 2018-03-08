$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'
require 'orb/devices/roku'

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
    
    def set_power_state state
      roku.power_on
    end
    
    def input text
    
    end    
  end
  
  def initialize config={}
    super config, RawDevice, config
  end
end
