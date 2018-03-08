$: << File.join(File.expand_path(File.dirname(__FILE__)), '..')

require 'orb/skill'
require 'orb/provider'

module ORB
  class DeviceSkill < ORB::Skill
    DEVICE_KEYWORDS = [
      /^(play|search|watch|listen|press|input|swipe)/,
    ]  
  
    module RawDevice
      include ORB::HasProvider
    
      def key_press        code;               end
      def repeat_key_press code, times;        end
      def swipe            dir;                end
      def input            data;               end
      def search           query, provider=nil;end
      def set_power_state  state;              end
      def play             item, provider=nil; end
    end
    
    class TestRawDevice
      include RawDevice
      
      RawDevice.instance_methods.each do |m|
        define_method m do |*o|
          p [m, *o]
        end
      end
    end 
  
    attr_reader :name, :raw, :config
    def initialize config={}, klass=TestRawDevice, *o
       @config = config
       @name = config['name']
       @raw  = klass.new(*o)
       
       super
       
       @raw.load_providers config
       
       matches(/^(press) (.*) (.*) times on #{name}/,
               /^(play) (.*) on (.*) from (.*) on #{name}/, 
               /^(play) (.*) from (.*) on #{name}/,
               /^(search) (.*) on (.*) on #{name}/, 
               /^(play|swipe|press|input|search) (.*) on #{name}/,
               /^(turn|power) (on|off) #{name}/)
    end
    
    def execute text
      case @match[2]
      when /turn|power/
        idx = ["off", "on"].index(@match[3])
        
        unless idx
          say "I do not know that power mode. Only ON and OFF"
          return ''
        end
        
        raw.set_power_state idx
      
      when "press"
        if @match[4]
          q = @match[4]
          q = 2 if q == "too" or q == "two" or q == "to"
          
          raw.repeat_key_press @match[3], q.to_i
        else
          raw.key_press @match[3]
        end
        
      when /(play|swipe|search|input)/
        cmd = $1
        
        cmd = "play_item" if cmd == "play"
        
        p match
        
        if text.scan("on").length > 1
          raw.send cmd.to_sym, "#{@match[3]} on #{@match[4]}", @match[5]
        else    
          raw.send cmd.to_sym, @match[3], @match[4] 
        end      
      else
        say "The device, #{name}, does not know that."
      
        return     
      end
      
      DeviceSkill.active_device = self
      
      say 'O K'
      ''
    end
    
    def on_active; end
    
    class << self
      attr_reader :active_device
      
      def active_device= d
        d.on_active if d
        @active_device = d
      end 
      
      def find name
        ORB::Skill.skills.find do |s|
          p [s.name, name] if s.respond_to?(:name)
          s.is_a?(ORB::DeviceSkill) and s.name == name
        end      
      end
    end
  end
end
