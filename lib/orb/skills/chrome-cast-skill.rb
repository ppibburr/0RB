$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'
require 'orb/devices/chromecast'

class ChromeCastSkill < ORB::DeviceSkill
  def initialize config={}
    super config, ChromeCast::Device, config['name'], config['ip']
  end
end
