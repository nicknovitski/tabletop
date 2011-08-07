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
end