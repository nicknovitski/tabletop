module Tabletop
  class Die
    include Comparable
    
    attr_reader :sides, :value

    # :sides must be greater than or equal to 2.  By default it is 6.
    # :value must be between 1 and :sides, inclusive.  By default it is random.
    def initialize(params={})
      if params[:sides].nil?
        @sides = 6
      else
        @sides = Integer(params[:sides])
        raise ArgumentError if @sides < 2
      end

      @possible_values = (1..sides).to_a

      if params[:value].nil?
        roll
      else
        set_to params[:value]
      end
    end

    def self.new_from_string(string)
      raise ArgumentError unless string.respond_to?(:split)
      v, s = string.split('/')
      Die.new(sides: s.to_i, value: v.to_i)
    end
    
    # Sets the die to a random number n, where 1 <= n <= @sides
    def roll
      set_to random_value
    end
    
    # Returns a string in the form "[#value]/d#sides"
    def to_s
      "[#{value}]/d#{sides}"
    end
    
    # Raises ArgumentError if new_value isn't between 1 and @sides inclusive
    def set_to(new_value)
      integer_value = Integer(new_value)
      raise ArgumentError unless valid_value?(integer_value)
      @value = integer_value
      self
    end
    
    # Compares based on value of the die
    def <=>(operand)
      value <=> operand.to_int
    end
    
    # Returns the die's value
    def to_int
      value
    end
    
    protected

    attr_reader :possible_values

    def valid_value?(val)
      possible_values.include?(val)
    end

    def random_value
      possible_values.sample 
    end
  end
  
  
  # A FudgeDie is a kind of three-sided Die that has a value
  # of either 0, 1, or -1.
  class FudgeDie < Die
    def initialize(params = {})
      super(sides: 3, value: params[:value])
    end
    
    # Returns either "[-]", "[ ]", or "[+]", depending on @value
    def to_s
      "[#{['-', ' ', '+'][value+1]}]"
    end
  
    protected
    def possible_values
      [-1, 0, 1]
    end
  end
  
  
  # A coin is a kind of two-sided Die that has a value of
  # either 0 or 1
  class Coin < Die
    def initialize(params={})
      super(sides: 2, value: params[:value])
    end

    alias_method :flip, :roll

    def set_to_heads
      set_to 1
    end

    def heads?
      value == 1
    end

    def set_to_tails
      set_to 0
    end

    def tails?
      value == 0
    end

    # Returns either "( )" or "(+)" depending on @value
    def to_s
      "(#{[' ', '+'][value]})"
    end
    
    protected
    def possible_values
      [0,1]
    end
  end
end
