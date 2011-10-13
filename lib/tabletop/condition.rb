module Tabletop
  class Condition
    def initialize(&block)
      @test = block
    end
    def met_by?(pool)
      @test.call(pool)
    end
  end
end