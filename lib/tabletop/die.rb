module Tabletop
  class Die
    include Comparable
    attr_reader :sides, :value
    def initialize(sides=6, init_value=nil)
      if sides <= 1
        raise ArgumentError, "Die cannot have #{sides} sides"
      end
      unless sides.kind_of? Integer
        raise ArgumentError, "Parameter must be Integer, not #{sides.class}"
      end
      @sides = sides
      if init_value.nil?
        init_value = roll
      else
        raise ArgumentError unless valid_value?(init_value)
      end
      @value = init_value
    end
    def roll
      @value = rand(sides)+1
    end
    def inspect
      "#{@value} (d#{@sides})"
    end
    def value=(new_value)
      raise ArgumentError unless valid_value?(new_value)  
      @value = new_value
    end
    def <=>(operand)
      @value <=> operand.to_int
    end
    def to_int
      @value
    end
    
    protected
    def valid_value?(val)
      val > 0 and val <= @sides
    end
  end
  
  class FudgeDie < Die
    def initialize(init_value = nil)
      super(3, init_value)
    end
    def roll
      @value = rand(sides)-1
    end
    def inspect
      "[#{['-', ' ', '+'][@value+1]}] (dF)"
    end
    
    protected
    def valid_value?(val)
      [1,0,-1].include?(val)
    end
  end
end