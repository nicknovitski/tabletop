require 'spec_helper'

require 'tabletop/table'

module Tabletop
  RSpec.describe Table do

    context 'when initialized with a hash' do
      let(:atmo_hash) {
        {
        2 => 'Corrosive',
        3 => 'Inert gas',
        4 => 'Airless or thin atmosphere',
        5..9 => 'Breathable mix',
        10 => 'Thick atmosphere, breathable with a pressure mask',
        11 => 'Invasive, toxic atmosphere',
        12 => 'Corrosive and invasive atmosphere'
      }
      }

      subject(:atmo_table) { Table.new(atmo_hash) }

      describe '#[]' do
        it 'delegates to the hash' do
          expect(atmo_table[2]).to eq atmo_hash[2]
        end

        it 'handles ranges as keys' do
          (5..9).each do |i|
            expect(atmo_table[i]).to eq atmo_hash[5..9]
          end
        end

        it 'raises KeyError for anything not in the table' do
          expect { atmo_table[13] }.to raise_exception KeyError
        end
      end
    end

    context 'when initialized with an array' do
      subject(:simple_table) { Table.new([:foo, :bar]) }
      describe '#[]' do
        it 'indexes from 1, not zero' do
          expect(simple_table[1]).to be :foo
          expect(simple_table[2]).to be :bar
        end

        it 'raises KeyError for anything not in the table' do
          expect { simple_table[0] }.to raise_exception KeyError
          expect { simple_table[3] }.to raise_exception KeyError
        end
      end
    end
  end
end
