
$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'

module ChromeCast  
  def self.get_binary
    "python3 -m catt.cli"
  end

  module RawChromeCast
    KEYS = {
      "volume up":   :volumeup,
      "volume down": :volumedown,
      "pause":       :pause,
      "play":        :play!
    }
    
    attr_accessor :ip, :name
    attr_writer :cc
    
    def cc
      @cc ||= self
    end
    
    def key_press key
      key = KEYS[key] || (KEYS.find do |k,v| key == v end)
    
      send key
    end
    
    def add source;
     # ...
      command :add, source
    end

    def cast source;
      # ...

      command :cast, source
    end

    def ffwd;
      # ...
      command :ffwd
    end

    def info;
     # ...
      command :info
    end

    def pause;
     # ...
       command :pause
    end

    def play!;
     # ...
      command :play
    end

    def rewind;
     # ...
      command :rewind
    end

    def scan;
      # ...
      command :scan
    end

    def seek pos;
     # ...
      command :seek, pos
    end

    def skip;
     # ...
      command :skip
    end

    def status;
     # ...
      command :status
    end

    def stop;
     # ...
      command :stop
    end

    def volume amt;
     # ...
      command :volume, amt
    end

    def volumedown;
     # ...
      command :volumedown
    end

    def volumeup;
     # ...
      command :volumeup
    end

    def write_config;
     # ...

    end
    
    private
    def command *o
      cmd="#{ChromeCast.get_binary} -d \"#{name}\" #{o.join(" ")}"
      p cmd if true
      `#{cmd}`
    end
  end
  
  class Device
    include ORB::DeviceSkill::RawDevice
    include ORB::Media::MediaDevice  
    include RawChromeCast
  
  
    def initialize name = nil, ip = nil
      @ip   = ip
      @name = name
    end
  end  
end
