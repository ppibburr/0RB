#!/usr/bin/env ruby
require 'json'

require 'ssdp'
require 'httparty'

module Roku
  class Device
    class Response
      attr_reader :response

      def initialize(res)
        @response = res
      end

      def ok?
        response.success?
      end

      def struct_from_response_key(key)
        hash = response.parsed_response[key].map do |k, v|
          v = true  if v == "true"
          v = false if v == "false"
          [k.to_sym, v]
        end.to_h
        Struct.new(*hash.keys).new(*hash.values)
      end
    end

    include HTTParty

    class CannotGetInfo < StandardError; end

    ROKU = 'roku:ecp'.freeze

    ACTIONS = {
      home: 'Home',
      reverse: 'Rev',
      forward: 'Fwd',
      play: 'Play',
      select: 'Select',
      left: 'Left',
      right: 'Right',
      down: 'Down',
      up: 'Up',
      back: 'Back',
      replay: 'InstantReplay',
      info: 'Info',
      del: 'Backspace',
      search: 'Search',
      enter: 'Enter',
      volume_up: 'VolumeUp',
      volume_down: 'VolumeDown',
      volume_mute: 'VolumeMute'
    }.freeze

    attr_reader :location, :boot_info

    def initialize(loc)
      class << self
        include HTTParty
      end

      @location = loc
      self.singleton_class.base_uri(location.to_s)
      @boot_info = info
    end

    def power_on
      Response.new(self.singleton_class.post('/launch/tvinput.hdm1'))
    end

    def info
      res = Response.new(self.singleton_class.get('/query/device-info'))
      raise CannotGetInfo unless res.ok?
      res.struct_from_response_key('device_info')
    end

    def press(keypress)
      if ACTIONS[keypress]
        Response.new(self.singleton_class.post("/keypress/#{ACTIONS[keypress]}"))
      elsif keypress.action
        Response.new(self.singleton_class.post("/keypress/#{ACTIONS[keypress.action]}"))
      elsif keypress.method
        send(keypress.method)
      else
        raise ArgumentError, "UnsureWhatThatKeyPressIs"
      end
      
      self
    end

    DIRECT_KEYS = [:up, :down, :left, :right, :ok, :home, :back, :reverse, :forward, :play, :select]

    DIRECT_KEYS.each do |m|
      define_method m do |*opts|
        map    = {delay: 0.33}     
      
        if opts.last.is_a?(Hash)
          map = opts.pop
        end
        
        repeat = opts[0] || 1
        
        repeat.times do
          if (map)[:delay]
            sleep map[:delay]
          end
        
          press m
        end
        
        self
      end
    end
    
    def find_then_play query, provider: nil
      STDERR.puts uri = "'192.168.1.130:8060/search/browse?keyword=#{query.gsub(" ", "%20")}#{provider ? "&provider=#{provider=netflix}" : ""}&launch=true&match-any=true'"
      `curl -d '' #{uri}`
    end

    def self.devices
      finder = SSDP::Consumer.new(timeout: 3)
      result = finder.search(service: ROKU)
      if result
        result.map do |res|
          Device.new(
            URI.parse(res[:params]['LOCATION'])
          )
        end
      else
        puts 'Cannot find a roku device..'
        false
      end
    end
    
    def self.find *opts, &b
      devices.find do |d|  
        if b
          res = b.call d
          next true if res and opts.empty?
        end
        
        info = d.boot_info
        
        if opts.last.is_a? Hash
          map = opts.pop        
        end
        
        opts.each do |o|
          unless info[o.to_sym]
            return nil
          end
        end
        
        (map || {}).each_pair do |k,v|
          return nil unless info[k] == v
        end
        
        true
      end    
    end
  end
end
