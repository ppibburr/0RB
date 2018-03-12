$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'


module IHome
  def self.get_key user, pass
    cmd = "curl -X POST "+
            "https://www.ihomeaudio.com/api/v3/login/ "+
            "-H 'cache-control: no-cache' "+
            "-H 'content-type: application/json' "+
            "-d '#{({email: user, password: pass}).to_json}'"
    
    puts cmd if true
        
    JSON.parse(`#{cmd}`)['evrythng_api_key']
  end
  
  def self.get_devices key
  	cmd = "curl -X GET "+
	        "'https://api.evrythng.com/thngs?perPage=100&sortOrder=DESCENDING' "+
	        "-H 'authorization: #{key}' "+
	        "-H 'cache-control: no-cache'"
	        
	  puts cmd if true
	
    JSON.parse(`#{cmd}`)
  end
  
  def self.account email, passwd
    {
      'key'     => key = get_key(email, passwd),
      'devices' => get_devices(key)
    }
  end

  class Device
    include ORB::DeviceSkill::RawDevice
  
    attr_reader :id, :config
    def initialize config
      p @config = config
      @id     = config['id']
    end
    
    def write uri, body
      cmd = "curl -X POST "+
            "#{uri} "+
            "-H 'authorization: #{config['key']}' "+
            "-H 'cache-control: no-cache' "+
            "-H 'content-type: application/json' "+
            "-d '#{body}'"  
            
      puts cmd if true
      
      `#{cmd}`
    end
    
    def properties
      uri = "https://api.evrythng.com/thngs/#{id}/properties"
    
      cmd = "curl "+
            "#{uri} "+
            "-H 'authorization: #{config['key']}' "+
            "-H 'cache-control: no-cache' "+
            "-H 'content-type: application/json' " +
            "-o -"
            
      puts cmd if true
      
      JSON.parse(`#{cmd}`)
    end
    
    def property name
      prop = (((a=properties).find do |o| o['key'] == name.to_s end) || {})["value"] 
      p a
      if prop.strip =~ /^([0-9]+)$/
        return $1.to_i
      end
      
      prop
    end    
  end


  module Plug
    include ORB::DeviceSkill::RawDevice
    
    def on;  end
    def off; end
  
    def on?
      property(:currentpowerstate1) == 1 
    end
  
    def off?
      !on?
    end
  
    def state
      on? ? 1 : 0
    end
    
    def key_press key
      return unless key == 'power'
    
      toggle
    end
   
    def set_power_state state
      send [:off,:on][state]
    end
  end

  class ISP5 < Device
    include Plug
    
    def on
      write "https://api.evrythng.com/thngs/#{id}/properties/targetpowerstate1", ([{value: 1}]).to_json
    end
    
    def off
      write "https://api.evrythng.com/thngs/#{id}/properties/targetpowerstate1", ([{value: 0}]).to_json
    end
  end

  class ISP6 < Device
    include Plug
    
    def on
      write "https://api.evrythng.com/thngs/#{id}/actions/_turnOn", ({type: '_turnOn'}).to_json
    end
    
    def off
      write "https://api.evrythng.com/thngs/#{id}/actions/_turnOff", ({type: '_turnOff'}).to_json
    end
  end
end
