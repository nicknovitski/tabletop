require 'spec_helper'
require 'tabletop/randomizers/d666'

module Tabletop
  describe D666 do
    describe '#possible_values' do
      it 'is all the three-digit combinations of 1 to 6' do
        (100..600).step(100) do |hundreds|
          (10..60).step(10) do |tens|
            (1..6).each do |ones|
              expect(subject.possible_values).to include hundreds+tens+ones
            end
          end
        end
      end
    end
  end
end

