$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'

class ADBDevice
  include ORB::DeviceSkill::RawDevice
  include ORB::Media::MediaDevice
  
  KEYS = {
    home:   3,
    back:   4,
    left:   21,
    right:  22,
    up:     19,
    down:   20,
    pause:  85,
    ok:     66,
    enter:  66,    
    select: 66,   
    play:   85,
    on:     26,
    off:    26,
    power:  26,
    menu:   82,
    search: 84,
  }

  def key_press key
    unless key.is_a?(Integer)
      key = KEYS[key.to_sym]
    end
    
    p [:KEY, key]
    
    return unless key
    
    input! keyevent: key
  end
  
  REPEAT_DELAY = 0.11
  def repeat_key_press key, times
    times.times do
      key_press key
      sleep REPEAT_DELAY
    end
  end

  def input text, *o
    input! text: text
  end
  
  def set_power_state state
    key_press [:off, :on][state]
  end
  
  def swipe dir
  
  end
  
  def search query, provider=nil
    if provider
      
    end
    
    key_press :search
    sleep 0.2
    input query
    sleep 0.1
    key_press :enter
  end
  
  def shell str
    cmd = "adb -s #{ip} shell #{str}"
    puts cmd if true
    `#{cmd}`
  end
  
  def tap x, y
    shell "input tap #{x} #{y}"
  end
  
  def swipe x,y,x1,y1
    shell "input swipe #{x} #{y} #{x1} #{y1}"
  end
  
  def toggle
    key_press :power
  end
  
  attr_accessor :ip, :name
  def initialize name=nil, ip=nil
    @ip   = ip
    @name = name
    p [:ip, ip]
    `adb connect #{ip}`
  end
  
  private
  def input! text: nil, keyevent: nil
    if text or keyevent
      cmd = "input #{keyevent ? "keyevent #{keyevent}" : "text \"#{text.gsub(" " , "%s")}\""}"
      shell cmd
    end
  end
end
