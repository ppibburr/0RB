$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'


class TPLinkPlug
  include ORB::DeviceSkill::RawDevice

  attr_reader :config
  def initialize config
    @config = config
  end

  def set_power_state state
    state = [:off, :on][state]
    cmd = "python #{ENV['HOME']}/tplink-smartplug.py -t #{config['ip']} -c #{state}"
    p cmd if true
    `#{cmd}`
  end
end
