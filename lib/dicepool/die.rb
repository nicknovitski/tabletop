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
      result ||= roll
      @result = result
    end
    def roll
      @result = rand(sides)+1
    end
    def inspect
      "#{@result} (d#{@sides})"
    end
    def result=(new_result)
      raise ArgumentError if (new_result <=0 or new_result > @sides) 
      @result = new_result
    end
  end
  
  class FudgeDie < Die
    def initialize(result = nil)
      @sides = 3
      if result.nil?
        roll
      elsif [1, 0, -1].include?(result)
        @result = result
      else
        raise ArgumentError
      end
    end
    def roll
      @result = rand(sides)-1
    end
    def result=(new_result)
      raise ArgumentError unless [1,0,-1].include?(new_result)
      @result = new_result
    end
    def inspect
      "[#{['-', ' ', '+'][@result+1]}] (dF)"
    end
  end
end