$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..')

require 'orb/provider'
require 'orb/media'

class CCBaseProvider < ORB::Media::MediaProvider
  def pause
    device.cc.key_press :pause
  end
  
  def play
    device.cc.key_press :play
  end  
  
  def initialize name
    super name
  end
end

class CCLocalProvider <  CCBaseProvider
  def initialize
    super 'storage'
  end
end
