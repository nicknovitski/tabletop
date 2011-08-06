module DicePool
  class Die
    attr_reader :sides, :result
    def initialize(sides=6)
      if sides <= 0
        raise ArgumentError, "Die cannot have #{sides} sides"
      end
      unless sides.kind_of? Integer
        raise ArgumentError, "Parameter must be Integer, not #{sides.class}"
      end
      @sides = sides
      @result = roll
    end
    def roll
      @result = rand(sides)+1
    end
  end
end