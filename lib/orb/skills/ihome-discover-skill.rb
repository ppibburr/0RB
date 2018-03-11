$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/skill'
require 'orb/devices/ihome'

class IHomeDiscoverSkill < ORB::Skill
  attr_reader :account
  def initialize *o
    super
    
    @account = {}
            
    add_route "/account" do |app|
      app.content_type "text/json"
      @account.to_json
    end
    
    add_route "/devices" do |app|
      app.content_type "text/json"    
      (@account['devices']||=[]).to_json 
    end
    
    add_route "/account/init" do
      @account = IHome.account(e=config['account']['email'], pass=config['account']['passwd'])

      render 
    end    
  end  
  
  def render app=nil
    "<b>IHome Account:</b> <code>#{config['account']['email']}</code><br>"+
    "<b>key</b>: <code>#{@account['key']}</code>"     
  end
end

