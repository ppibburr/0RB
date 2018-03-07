module ORB
  class Provider
    attr_reader :name
    def initialize name
      @name = name
    end
    
    def play_item  item, device; end
    def watch      item, device; end
    def search     item, device; end
  end
  
  module HasProvider    
    def find_provider name
      providers[name.to_sym]
    end    
    
    def add_provider name, provider
      providers[name.to_sym] = provider
    end    
    
    def providers
      @providers ||= {}
    end
  end
end