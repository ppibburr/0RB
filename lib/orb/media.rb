$: << File.join(File.expand_path(File.dirname(__FILE__)), '..')

require "orb/skill"
require "orb/provider"

module ORB
  module Media
    # Included by media skills
    module MediaControls
      # the encapsualted player object of the active media skill
      attr_reader :player
      
      def execute text=''
        # [play|pause|stop|<next|previous> track] will default to below
        MediaSkill.instance.player = self  
      end
      
      def pause
        player.pause
      end
      
      def prev
        player.prev
      end
      
      def next
        player.next
      end
      
      def play
        player.play
      end 
      
      def stop
        player.stop
      end    
    end

    # Delegates to active playback skill
    class MediaSkill < Skill
      include MediaControls
      
      # the Actvie playback skill
      attr_accessor :player
      
      def initialize
        super
        matches(/^pause$/, /^play$/, /^resume$/, /^next track$/, /^stop$/, /^next$/, /^prev$/, /^previous track$/)
      end
      
      attr_accessor :default_player
      
      def execute text
        if !player
          if !ORB::Media::MediaSkill.instance.player and d=ORB::Media::MediaSkill.instance.default_player
            p @player = d
          else
            return ''
          end
        end
      
        pause      if text.strip == "pause"
        play       if text.strip == "play"
        play       if text.strip == "resume"
        self.next  if text.strip =~ /next/
        prev       if text.strip =~ /prev/    
        stop       if text.strip == "stop"        
        
        ''
      end
      
      def self.instance
        @instance ||= new
      end
      
      instance
    end
    
    module MediaDevice
      def play_item item, provider
		if !provider
		  
		elsif provider=find_provider(provider)
		  provider.play_item item, self
		end
      end
      
      def watch     item, device; end
      def search    item, device; end
    end    
    
    class MediaProvider < ORB::Provider
      include ORB::Media::MediaControls

      attr_reader :device
      def initialize *o
        super
        
        @player = self
      end
      
      def play_item item, device
        @device = device
        
        ORB::Media::MediaSkill.instance.player = self
          
        super
      end
    end
  end
end
