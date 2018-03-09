$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/device'
require 'rubygems'
require 'waveinfo'

class Text2CCSkill < ORB::Skill
  def initialize config={}
    super()
  end
  
  def matches *list
    if list.empty?
      @matches = [/^broadcast (.*)/].push(*ORB::DeviceSkill.devices.map do |d|
        [/^tell (#{d.name!}) (.*)/, /^announce on #{d.name!} (.*)/]
      end.flatten)
    else
      super
    end
  end
  
  attr_reader :mimic, :voice
  def execute text
    if text =~ /^broadcast (.*)/
      `#{ORB::Skill.get_speak_command($1)} -o #{file= "./tmp-cc.wav"}`
      wave = WaveInfo.new(file) 
      
      ORB::DeviceSkill.devices.find_all do |d|
        d.config['providers'].find do |p| p['class'] == 'CCLocalProvider' end
      end.each do |d|
        send_msg d, file: file, wave: wave
      end
    else
      send_msg((ORB::DeviceSkill.devices.find do |d| d.name.downcase == @match[2] end), message_text: @match[3])
    end
    
    ''
  end
  
  def send_msg d, message_text: nil, mimic: @file, voice: @voice, file: nil, wave: nil
    if !file
      `#{ORB::Skill.get_speak_command(message_text, mimic: mimic, voice: voice)} -o #{file='tmp-cc.wav'}`
    end
     wave ||= WaveInfo.new(file)    
     Thread.new do
       t=Thread.new do
         cmd = "python3 -m catt.cli -d \"#{d.name}\" cast #{file}"
         p cmd if true
         `#{cmd}` if file
       end
       sleep wave.duration+4
       t.kill
     end
     
  end
end

