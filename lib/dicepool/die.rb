module DicePool
  class Die
    attr_reader :sides, :result
    def initialize(sides=6)
      raise ArgumentError if (sides <= 0 or sides.class != Fixnum)
      @sides = sides
      @result = roll
    end
    def roll
      @result = rand(sides)+1
    end
  end
end