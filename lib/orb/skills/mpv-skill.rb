$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/media'

require "mpv"

class MPVSkill < ORB::Skill
  include ORB::Media::MediaControls

  class Player < MPV::Session
    def initialize
      super(user_args: ['--no-video'])
      def client.socket
        @socket
      end
    end

    def load f
      command "loadfile", f
    end
    
    def append f
      command "loadfile", f, 'append-play'
    end
    
    def next
      command "playlist_next"
    end
    
    def prev
      command "playlist_prev"
    end  
    
    def pause
      command "cycle", "pause"
    end

    def play
      command "cycle", "pause"
    end
    
    def stop
      pause
    end
  end

  def player
    @player ||= Player.new
  end

  def play_songs songs, shuffle = false
    say "Playing"
        
    player.load songs.shift

    (shuffle ? songs.shuffle : songs).each do |a|
      player.append a
    end
    
    if player.get_property "pause"
      play
    end
  end

  def search_yt query
    uri = "https://www.youtube.com/results?search_query=#{query.gsub(" ", "+")}"
    result = open(uri).read
    songs = result.scan(/(\/watch\?.*?v\=.*?)\&amp\;/).map do |u| "http://youtube.com#{u[0]}" end
    
    if !songs or songs.empty?
      say "No results found. Sorry"
      
      return
    end
    
    songs
  end
  
  def initialize
    super
    player
    
    matches(/play (.*) from youtube/, /play (.*) music/, /play (.*) on youtube/) 
  end
  
  def execute text=''
     super
     
     songs = search_yt match[2]
     
     if !songs or songs.empty?
       return
     end
     
     play_songs songs, true
     
     ''
  end
  
  def self.instance
    @ins ||= new
  end
  
  instance
end
