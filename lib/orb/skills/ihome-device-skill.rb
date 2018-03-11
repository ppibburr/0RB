$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'
require 'orb/devices/ihome'

class IHomeDeviceSkill < ORB::DeviceSkill
  def initialize config, klass, *o
    super config, klass, *o
  end
end

class IHomeISP5Plug < IHomeDeviceSkill
  def initialize config
    super config, IHome::ISP5, config
  end
end

class IHomeISP6Plug < IHomeDeviceSkill
  def initialize config
    super config, IHome::ISP5, config
  end
end
