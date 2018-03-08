$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'
require 'orb/devices/adb'

class AndroidADBSkill < ORB::DeviceSkill
  def initialize config={}
    super config, ADBDevice, config['ip']
  end
  
  def store
    ORB.save_device(({name: name, ip: raw.ip}).to_json)
  end
  
  def self.load name: nil, ip: nil
    ORB.load_device(name: name, ip: ip)
  end
end
