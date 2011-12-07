module Tabletop
  class Die
    include Comparable
    
    attr_reader :sides, :value

    # :sides must be greater then or equal to 1.  By default it is 6.
    # If :value is nil, then #roll is called.
    def initialize(params={})

      if params[:sides].nil?
        @sides = 6
      else
        @sides = Integer(params[:sides])
        raise ArgumentError if @sides < 2
      end

      if params[:value].nil?
        roll
      else
        self.value = params[:value]
      end
    end

    def self.new_from_string(string)
      raise ArgumentError unless string.respond_to?(:split)
      v, s = string.split('/')
      Die.new(sides: s.to_i, value: v.to_i)
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
      integer_value = Integer(new_value)
      raise ArgumentError unless valid_value?(integer_value)
      @value = integer_value
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
      0 < val and @sides >= val
    end
  end
  
  
  # A FudgeDie is a kind of three-sided Die that has a value
  # of either 0, 1, or -1.
  class FudgeDie < Die
    def initialize(params = {})
      super(sides: 3, value: params[:value])
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
    def initialize(params={})
      super(sides: 2, value: params[:value])
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