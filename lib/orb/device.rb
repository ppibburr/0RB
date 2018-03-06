$: << File.join(File.expand_path(File.dirname(__FILE__)), '..')

require 'orb/skill'

module ORB
  class DeviceSkill < ORB::Skill
    module RawDevice
      def key_press        code;        end
      def repeat_key_press code, times; end
      def swipe            dir;         end
      def input            data;        end
      def search           query;       end
      def set_power_state  state;       end
      def play             item;        end
    end
    
    class TestRawDevice
      include RawDevice
      
      RawDevice.instance_methods.each do |m|
        define_method m do |*o|
          p [m, *o]
        end
      end
    end 
  
    attr_reader :name, :raw
    def initialize name
       @name = name
       @raw  = TestRawDevice.new
       
       super
       
       matches(/(press) (.*) (.*) times on #{name}/, /(play|swipe|press|input|search) (.*) on #{name}/, /(turn|power) (on|off) #{name}/)
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
        raw.send $1.to_sym, @match[3]            
      end
      
      say 'O K'
      ''
    end
  end
end
