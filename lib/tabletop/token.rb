module Tabletop
  class TokenStack
    attr_accessor :count
    
    def initialize
      @count = 1
    end
    
    def add(n = 1)
      raise ArgumentError unless Fixnum === n and n > 0
      @count += n
    end
    
  end
end