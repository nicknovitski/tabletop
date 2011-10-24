module Tabletop

  # Stores a block to evaluate against a Pool
  class Condition
    def initialize(&block)
      @test = block
    end

    # returns false if the stored block evaluates to false or nil,
    # otherwise returns true
    def met_by?(pool)
      if @test.call(pool)
        true
      else
        false
      end
    end
  end

end