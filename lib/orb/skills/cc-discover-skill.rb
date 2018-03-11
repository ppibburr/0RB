$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/skill'
require 'orb/devices/chromecast'

class ChromeCastDiscover < ORB::Skill
  def initialize *o
    super 
    
    add_route "/discover" do |app|
      app.content_type "text/json"
      
      `#{[ChromeCast.get_binary, :scan].join(" ")}`
    end
  end
end

