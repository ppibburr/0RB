$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'
require 'orb/devices/tplink'

class TPLinkWIFIPlugSkill < ORB::DeviceSkill
  def initialize config={}
    super config, TPLinkPlug, config
  end
end
