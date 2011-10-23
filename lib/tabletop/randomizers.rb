module Tabletop
  class Die
    include Comparable
    
    attr_reader :sides, :value

    # Sides must be greater then or equal to 1.  
    # If init_value is nil, then #roll is called. 
    def initialize(params={})
      params[:sides] ||= 6
      if params[:sides] <= 1
        raise ArgumentError, "Die cannot have #{sides} sides"
      end
      unless params[:sides].kind_of? Integer
        raise ArgumentError, "Parameter must be Integer, not #{sides.class}"
      end
      @sides = params[:sides]

      params[:value] ||= roll
      raise ArgumentError, "Value #{params[:value]} invalid for randomizer of #{@sides} sides" unless valid_value?(params[:value])
      @value = params[:value]
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
      val > 0 and val <= @sides and val.kind_of?(Integer)
    end
  end
  
  
  # A FudgeDie is a kind of three-sided Die that has a value
  # of either 0, 1, or -1.
  class FudgeDie < Die
    def initialize(val = 0)
      super(sides: 3, value: val)
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
    def initialize(val=0)
      super(sides: 2, value: val)
    end
    
    def roll #:nodoc:
      @value = rand(sides)
    end
    
    # set to a random value, then return itself 
    def flip
      roll
      self
    end

    def heads?
      @value == 1
    end

    def tails?
      @value == 0
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