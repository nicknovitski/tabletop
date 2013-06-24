require_relative 'die'

module Tabletop
  # A FudgeDie is a kind of three-sided Die that has a value
  # of either 0, 1, or -1.
  class FudgeDie < Die
    def initialize(params = {})
      super(params.merge(:possible_values => [-1,0,1]))
    end

    # Returns either "[-]", "[ ]", or "[+]", depending on @value
    def to_s
      "[#{['-', ' ', '+'][value+1]}]"
    end
  end
end
