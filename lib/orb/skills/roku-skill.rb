$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'
require 'orb/devices/roku'

class RokuSkill < ORB::DeviceSkill
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
    roku(*opts)
  end
end
