module Tabletop
  class Die
    include Comparable
    
    attr_reader :sides, :value
    
    # Sides must be greater then or equal to 1.  
    # If init_value is nil, then #roll is called. 
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
    
    # Sets @value to a random number n, where 1 <= n <= @sides
    def roll
      @value = rand(sides)+1
    end
    
    # Returns a string in the form "[@value]/d@sides"
    def to_s
      "[#{value}]/d#{sides}"
    end
    
    # Raises ArgumentError if new_value isn't between 1 and @sides inclusive
    def value=(new_value)
      raise ArgumentError unless valid_value?(new_value)  
      @value = new_value
    end
    
    # Compares based on value of the die
    def <=>(operand)
      @value <=> operand.to_int
    end
    
    # Returns the die's value
    def to_int
      @value
    end
    
    protected
    def valid_value?(val)
      val > 0 and val <= @sides
    end
  end
  
  
  # A FudgeDie is a kind of three-sided Die that has a value
  # of either 0, 1, or -1.
  class FudgeDie < Die
    def initialize(init_value = nil)
      super(3, init_value)
    end
    def roll
      @value = rand(sides)-1
    end
    
    # Returns either "[-]", "[ ]", or "[+]", depending on @value
    def to_s
      "[#{['-', ' ', '+'][@value+1]}]"
    end
  
    protected
    def valid_value?(val)
      [1,0,-1].include?(val)
    end
  end
  
  
  # A coin is a kind of two-sided Die that has a value of
  # either 0 or 1
  class Coin < Die
    def initialize(value=nil)
      super(2, value)
    end
    
    def roll #:nodoc:
      @value = rand(sides)
    end
    
    # set to a random value, then return itself 
    def flip
      roll
      self
    end
    
    # Returns either "( )" or "(+)" depending on @value
    def to_s
      "(#{[' ', '+'][value]})"
    end
    
    protected
    def valid_value?(val)
      [0,1].include?(val)
    end
  end
end