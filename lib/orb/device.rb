$: << File.join(File.expand_path(File.dirname(__FILE__)), '..')

require 'orb/skill'
require 'orb/provider'

module ORB
  class DeviceSkill < ORB::Skill
    DEVICE_KEYWORDS = [
      /^(play|search|watch|listen|press|input|swipe|cast|toggle)/,
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
      
      def ui_key key
        key_press key
        
        nil
      end
      
      def on?; end
      def off?; end
      
      def state; end
      
      def toggle
        on? ? off : on
      end
    end
    
    class TestRawDevice
      include RawDevice
      
      RawDevice.instance_methods.each do |m|
        define_method m do |*o|
          p [m, *o]
        end
      end
    end 
  
    attr_reader :raw, :config, :name, :raw_params, :raw_class
    def name!; @name.downcase; end
    def initialize config={}, klass=TestRawDevice, *o
       @config = config
       @name = config['name']

       @raw_params = o
       @raw_class  = klass
       
       super config
       
       init
    end
  
    def init
      super
    
      @raw  = raw_class.new(*raw_params)
     
      @matches = []
    
      @raw.load_providers config
       
      matches(/^(press) (.*) (.*) times on #{name!}/,
              /^(play) (.*) on (.*) from (.*) on #{name!}/, 
              /^(play) (.*) from (.*) on #{name!}/,
              /^(cast) (.*) on (.*) from (.*) on #{name!}/, 
              /^(cast) (.*) from (.*) on #{name!}/,               
              /^(search) (.*) on (.*) on #{name!}/, 
              /^(play|swipe|press|input|search|cast) (.*) on #{name!}/,
              /^(turn|power) (on|off) the #{name!}/,
              /^(turn|power) (on|off) #{name!}/,
              /^(toggle) #{name!}/,               
              /^(#{name!}) (on|off)/)    
    end 
    
    def match? text
      if text=~/^ui\-/
        text = text.gsub(/^ui\-/,'')
        r = super(text)
        if r
          @ui_evt=true
          return r
        end
        
        @ui_evt=false
        text = "ui-"+text
      end
      
      @ui_evt=false
      
      super text       
    end
    
    def ui
      """
<!DOCTYPE html>      
      <html></head><meta name=viewport content='width=device-width, initial-scale=1.0'><meta name=apple-mobile-web-app-capable content='yes'>
<meta name='mobile-web-app-capable' content='yes'>
</head>
      <style>
        body {
          background-color: black;
          width:100%;
          max-width:100vw;
          margin:0;
          padding:0;
        }
        
        .button {
          border-radius: 2em;
        }
        
        #up {
          position: relative;
          left:6px;        
          margin-left:33%;
          width:33%;
          height:2em;
          border-top-right-radius: 2em !important;
          border-top-left-radius: 2em !important;
        }
        #down {
          position: relative;
          left:6px;
          margin-left:33%;
          width:33%;
          height:2em;
          border-bottom-right-radius: 2em !important;
          border-bottom-left-radius: 2em !important;
        }
        #left {
          margin-left:20%;
          width:16.66%;
          height:4em;
          border-top-left-radius: 2em !important;
          border-bottom-left-radius: 2em !important;
        }
        #right {
          /*margin-left:25%;*/
          width:16.66%;
          height:4em;
          border-top-right-radius: 2em !important;
          border-bottom-right-radius: 2em !important;
        }       
        #enter {
          border-radius:3em;
          height:20vw;
          width:20vw;
          margin: 12px;
        } 
        #power {
          position: absolute;
          width:19%;
          left:80%;
          height:3em;
        }
        #home {
          height:3em;
          margin-right:1em;
        }
        #back {
          height:3em;
        }
        #input {
          margin-right:12px;
        }
        
        #bottom {
          width:100%;
          margin-left: 22%;
          flex-grow:3;
        }
        
        #bottom button {
          width: 16%;
          height: 3em;
        }        
        
        #toggle {
          width: 24% !important;
        }        

        #top {flex-grow:1;}
    

        #second {
          width:100%;
          margin-left: 22%;
         flex-grow:2;
        }
        
        #second button {
          width: 16%;
          height: 3em;
        }        
        
        #menu {
          width: 24% !important;
        }
        
        #back {
           border-top-right-radius: 0px;
           border-bottom-right-radius: 0px;
        }

        #prev {
           border-top-right-radius: 0px;
           border-bottom-right-radius: 0px;
        }

        #next {
           border-top-left-radius: 0px;
           border-bottom-left-radius: 0px;
        }
        
        #nav {
          width:100%;
          flex-grow:6;
        }
        
        #container {
          height:100vh;
          width:100vw;
          display: flex;
          flex-direction:column;
        }
      </style>
      <body>
      <div id=container>
      <div id=top>
      <button id=back class=button>Back</button><button id=home class=button>HOME</button><button id=input class=button>Input</button><button class=button>Search</button><button id=power class=button>I/O</button><br></br>
      </div>
      <div id=second>
        <button id=vol_down class=button>-</button> 
        <button id=menu class=button>*</button>
        <button id=vol_up class=button>+</button> 
      </div>

      <div id=nav>
      <button id=up>up</button><br>
      <button id=left>left</button>
      <button id=enter>enter</button>      
      <button id=right>right</button><br>      
      <button id=down>down</button><br>   
      </div>
      
      <div id=bottom>
        <button id=prev class=button>prev</button> 
        <button id=toggle class=button>play</button>
        <button id=next class=button>next</button> 
      </div>
      </div>
      <script>

      var l = ['up','down','left','right','enter','home','back', 'menu', 'power'];
      for (i=0; i < l.length; i++) {
        console.log(l)
        document.getElementById(l[i]).onclick = keypress;
      }
      
      function keypress(e) {
        var key = this.id;
        console.log(key);
        var xmlhttp = new XMLHttpRequest();   // new HttpRequest instance 
        xmlhttp.open('POST', '/command');
        xmlhttp.setRequestHeader('Content-Type', 'application/json');
        xmlhttp.send('{\"text\": \"ui-press '+key+' on #{name.downcase}\"}');
      }
      //document.body.requestFullscreen();
      </script>
      """
    end
    
    def execute text
      sound = 'O K'
      case @match[2]
      
      when /turn|power|#{name}/
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
          raw.key_press @match[3]     if !@ui_evt
          sound=raw.ui_key(@match[3]) if @ui_evt
        end
        
      when /(play|swipe|search|input|cast)/
        cmd = $1
        
        cmd = "play_item" if cmd =~ /play|cast/
        
        
        
        if text.scan(/ on /).length > 1
          rest = [@match[5]]
          
          if cmd == "play_item"
            rest match
          end
          
          raw.send cmd.to_sym, "#{@match[3]} on #{@match[4]}", *rest
        else    
          rest = [@match[4]]
          
          if cmd == "play_item"
            rest << match
          end
     
          raw.send cmd.to_sym, @match[3], *rest
        end      
      when /toggle/
        raw.toggle
      else
        say "The device, #{name}, does not know that."
      
        return     
      end
      
      DeviceSkill.active_device = self
      
      say sound if sound
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
          s.is_a?(ORB::DeviceSkill) and ((s.name == name) or (s.name! == name))
        end      
      end
      
      def devices
        ORB::Skill.skills.find_all do |s|
          s.is_a?(ORB::DeviceSkill)
        end      
      end      
    end
  end
end
