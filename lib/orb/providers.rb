module ORB
  class Provider
    attr_reader :name
    def initialize name
      @name = name
    end
    
    def play   item, device; end
    def watch  item, device; end
    def search item, device; end
  end
end
