require_relative 'die'

module Tabletop
  class D66 < Die
    def initialize
      vals = []
      (10..60).step(10) do |tens|
        (1..6).each do |ones|
          vals << tens + ones
        end
      end
      super(:possible_values => vals)
    end
  end
end

