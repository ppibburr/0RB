$: << File.join(File.expand_path(File.dirname(__FILE__)), '..')

require 'json'
require 'open-uri'

require "orb"

module ORB
  class Skill
    MIMIC_PATHS = {
      system: File.expand_path("/opt/mycroft/voices/mimic_tn"),
      source: File.expand_path("#{ENV['HOME']}/mycroft-core/mimic/mimic")
    }
    
    def say text, voice: nil, mimic: :system
      system ORB::Skill.get_speak_command(text, voice: voice, mimic: mimic)
    end
    
    def self.get_speak_command text, voice: nil, mimic: nil
      mimic = MIMIC_PATHS[mimic]
      
      mimic = MIMIC_PATHS[:source] if !mimic or !File.exist?(mimic) or (voice and mimic == MIMIC_PATHS[:system])
      mimic = MIMIC_PATHS[:system] if !mimic or !File.exist?(mimic)
    
      cmd="#{mimic} -t \" #{text}\"#{voice ? " -voice #{voice}" : ''}"
      
      p cmd if true
      
      cmd    
    end
    
    attr_reader :match
    def match? text  
      (matches).find do |m|
        if text =~ m
          @match = [m].push(*$~)
        end
      end
    end
    
    def execute text
      say text
      
      return text
    end
    
    def self.skills
      @skills ||= []
    end
    
    attr_reader :config, :name
    def initialize config={}, *o
      @config=config
      @name = config['name'] ||= "NoName"
      Skill.skills << self
      add_route "" do |app|
        render app
      end
    end
    
    def render app=nil
      app.content_type "text/plain"
      self.inspect
    end
    
    def self.routes
      @routes ||= {}
    end
    
    def add_route r, &b; p :route, r
      p r = "/skill/#{name}#{r == "" ? "" : "/"}#{r.gsub(/^\//,'')}".gsub(" ","+")
      Skill.routes[r] = b
      Skill.route.send :get, r do
        p r
        p Skill.routes
        Skill.routes[r].call self
      end
    rescue => e
      p e
    end    
    
    def matches *r
      @matches = r if !r.empty?
      @matches ||= []
    end
    
    def self.find text
      skills.find do |s| s.match? text end
    end
    
    class << self
      attr_accessor :route
    end        
  end

  class UnhandledSkill < Skill
    def execute text="Sorry. I do not know that one."
      say text
      ''
    end
    
    def self.execute text="Sorry. I do not know that one."
      (@ins ||= new).execute text
    end
  end


  class SelfSkill < Skill
    def initialize
      super
      matches(/naked/, /color is your underwear/, /wearing panties|underwear/)
    end
    
    def execute text
      case matches.index(@match[0])
      when 0
        say "Yes"
      when 1
        say "None"
      when 2
        say "Silly, I am naked"
      else
        UnhandledSkill.execute
      end
      ''
    end

    def self.instance
      @instance ||= new
    end
    
    instance
  end
end
