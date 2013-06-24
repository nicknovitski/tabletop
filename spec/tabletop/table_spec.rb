require 'spec_helper'

module Tabletop
  describe Table do

    subject(:atmo_table) {
      Table.new(
        2 => 'Corrosive',
        3 => 'Inert gas',
        4 => 'Airless or thin atmosphere',
        5..9 => 'Breathable mix',
        10 => 'Thick atmosphere, breathable with a pressure mask',
        11 => 'Invasive, toxic atmosphere',
        12 => 'Corrosive and invasive atmosphere'
      )
    }

    describe '#[]' do
      it 'accesses values in the enumerable passed to the constructor' do
        expect(atmo_table[2]).to eq 'Corrosive'
      end

      it 'accesses values in ranges' do
        (5..9).each do |i|
          expect(atmo_table[i]).to eq 'Breathable mix'
        end
      end
      
      it 'raises KeyError for anything not in the table' do
        expect { atmo_table[13] }.to raise_exception KeyError
      end
    end
  end
end
