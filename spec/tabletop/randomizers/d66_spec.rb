require 'spec_helper'
require 'tabletop/randomizers/d66'

module Tabletop
  describe D66 do
    describe '#possible_values' do
      it 'is all the two-digit combinations of 1 to 6' do
        expect(subject.possible_values).to eq [
          11,12,13,14,15,16,
          21,22,23,24,25,26,
          31,32,33,34,35,36,
          41,42,43,44,45,46,
          51,52,53,54,55,56,
          61,62,63,64,65,66
        ]
      end
    end
  end
end

