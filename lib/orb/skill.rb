$: << File.join(File.expand_path(File.dirname(__FILE__)), '..')

require 'json'
require 'open-uri'

require "orb"

module ORB
  class Skill
    MIMIC_PATH = File.expand_path("#{ENV['HOME']}/mycroft-core/mimic/mimic")

    def say text
      cmd="#{MIMIC_PATH} -t \" #{text}\""
      system cmd
    end
    
    attr_reader :match
    def match? text  
      (@matches ||= []).find do |m|
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
    
    def initialize *o
      Skill.skills << self
    end
    
    def matches *r
      @matches = r
    end
    
    def self.find text
      skills.find do |s| s.match? text end
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
      case @matches.index(@match[0])
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
