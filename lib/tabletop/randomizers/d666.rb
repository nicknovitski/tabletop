require_relative 'die'

module Tabletop
  class D666 < Die
    def initialize
      vals = []
      (100..600).step(100) do |hundreds|
        (10..60).step(10) do |tens|
          (1..6).each do |ones|
            vals << hundreds + tens + ones
          end
        end
      end
      super(:possible_values => vals)
    end
  end
end

