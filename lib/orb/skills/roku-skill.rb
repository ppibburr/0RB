$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'
require 'orb/devices/roku'

class RokuSkill < ORB::DeviceSkill
  include ORB::DeviceSkill::RawDevice

  def roku(*opts)
    return @roku if @roku and opts.empty?
    
    3.times do
      break if @roku = Roku::Device.find(*opts)
    end
    
    fail "No Roku" unless @roku
    
    @roku
  end

  def intialize name, *opts
    super name
    @raw = self
    roku(*opts)
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
  
  def input text
  
  end
  
  def search query
  
  end
  
  def play item, *opts
    roku.find_then_play item
  end
end
