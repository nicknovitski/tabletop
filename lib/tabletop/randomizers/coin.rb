require_relative 'randomizer'
require 'set'

module Tabletop
  class Coin < Randomizer
    def initialize(keywords={})
      super(keywords.merge(:possible_values => [0,1]))
    end

    def flip
      set_to random_value
    end

    def heads?
      value == 1
    end

    def tails?
      value == 0
    end

    def set_to_heads
      set_to(1)
    end

    def set_to_tails
      set_to(0)
    end

    # Returns either "( )" or "(+)" depending on #value
    def to_s
      "(#{[' ', '+'][value]})"
    end
  end
end
