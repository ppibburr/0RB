$: << File.expand_path(File.dirname(__FILE__))

require 'json'

module ORB
  ORB_CONFIG_PATH = "#{ENV['HOME']}/.orb/"
  
  `mkdir -p #{ORB_CONFIG_PATH}`

  [DEVICES_CONFIG_PATH  = File.join(ORB_CONFIG_PATH, "devices.json"),
  CONTACTS_CONFIG_PATH  = File.join(ORB_CONFIG_PATH, "contacts.json"),
  MAIL_CONFIG_PATH      = File.join(ORB_CONFIG_PATH, "mail.json")].each do |f|
    if !File.exist?(f)
      File.open(f, 'w') do |o| o.puts({}.to_json) end
    end
  end
  
  SKILLS_CONFIG_PATH = f = File.join(ORB_CONFIG_PATH, "skills.json")
  
  if !File.exist?(f)
    File.open(f, 'w') do |o|
      o.puts([
        {
          name:  'sms',
          class: 'SMSSkill',
        }, 
        {
          name:  'mail',
          class: 'SendMailSkill'
        }
      ].to_json)
    end
  end

  def self.config(path)
    JSON.parse(open(path).read)
  end

  def self.load_devices
    config(DEVICES_CONFIG_PATH).each do |d|
      Thread.new do
        get_device_class(d['class']).new(d)
      end
    end
  rescue => e
    p e
    p e.backtrace
  end 
  
  def self.load_skills
    config(SKILLS_CONFIG_PATH).each do |s|
      Thread.new do
        get_device_class(s['class']).new(s)
      end
    end
  rescue => e
    p e
  end  
  
  def self.get_device_class str
    c = ::Object
    
    str.split("::").each do |e|
      c = c.const_get e.to_sym
    end
    
    c
  end
  
  def self.init route
    Skill.route = route
  
    load_devices
    load_skills
  end
end

require "orb/skill"
ORB::Skill.route = self
require "orb/media"
require 'orb/device'
