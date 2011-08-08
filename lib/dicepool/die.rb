module DicePool
  class Die
    attr_reader :sides, :result
    def initialize(sides=6, result=nil)
      if sides <= 0
        raise ArgumentError, "Die cannot have #{sides} sides"
      end
      unless sides.kind_of? Integer
        raise ArgumentError, "Parameter must be Integer, not #{sides.class}"
      end
      @sides = sides
      if result.nil?
        result = roll
      else
        raise ArgumentError unless valid_result?(result)
      end
      @result = result
    end
    def roll
      @result = rand(sides)+1
    end
    def inspect
      "#{@result} (d#{@sides})"
    end
    def result=(new_result)
      raise ArgumentError unless valid_result?(new_result)  
      @result = new_result
    end
    
    protected
    def valid_result?(result)
      result > 0 and result <= @sides
    end
  end
  
  class FudgeDie < Die
    def initialize(result = nil)
      super(3, result)
    end
    def roll
      @result = rand(sides)-1
    end
    def inspect
      "[#{['-', ' ', '+'][@result+1]}] (dF)"
    end
    
    protected
    def valid_result?(result)
      [1,0,-1].include?(result)
    end
  end
end