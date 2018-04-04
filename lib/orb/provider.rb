module ORB
  class Provider
    attr_reader :name, :match
    def initialize name, match=[]
      @name  = name
      match << name
      @match = match
    end
    
    def play_item  item, device; end
    def watch      item, device; end
    def search     item, device; end
    
    def match? n
      @match.index(n.to_s)
    end
  end
  
  module HasProvider
    def load_providers config
      (config['providers'] ||= []).each do |p|
        add_provider p['name'], ::Object.const_get(p['class'].to_sym).new
      end    
    end
      
    def find_provider name, match=nil
      p providers, name
      if m = providers.find do |n, p|
        n == name.to_sym or p.match?(name)
      end
        m[1]
      end
    end    
    
    def add_provider name, provider
      providers[name.to_sym] = provider
    end    
    
    def providers
      @providers ||= {}
    end
  end
end
