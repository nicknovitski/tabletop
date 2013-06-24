require 'tabletop/randomizers/die'

require 'spec_helper'
require_relative 'randomizer_spec'

module Tabletop
  describe Die do
    it_behaves_like 'a randomizer', :roll

    describe ".new_from_string" do
      it "expects a string in the format 'n/o', where n and o are integers" do
        d = Die.new_from_string('4/5')
        expect(d.sides).to eq 5
        expect(d.value).to eq 4
        expect {Die.new_from_string('10')}.to raise_error(ArgumentError)
        expect {Die.new_from_string(4/5)}.to raise_error(ArgumentError)
      end
    end

    describe "#sides" do
      it "can be accessed" do
        (2..10).each do |i|
          expect(Die.new(sides: i).sides).to eq i
        end
      end

      it "is 6 by default" do
        expect(Die.new.sides).to eq 6
      end

      it "cannot be 1 or less" do
        expect { Die.new(sides: 0) }.to raise_error(ArgumentError)
        expect { Die.new(sides: 1) }.to raise_error(ArgumentError)
        expect { Die.new(sides: -5) }.to raise_error(ArgumentError)
      end

      it "is cast as an integer" do
        expect { Die.new(sides: 0.1) }.to raise_error(ArgumentError)
        expect(Die.new(sides: 5.7694).sides).to eq 5
        expect(Die.new(sides: "10").sides).to eq 10
        expect { Die.new(sides: "foof") }.to raise_error(ArgumentError)
      end
    end

    describe "#value" do
      it "can be set to a given value on instantiation" do
        expect(Die.new(value: 5).value).to eq 5
        expect(Die.new(sides: 10, value: 2).value).to eq 2
      end
    end

    describe "#set_to" do
      it "can only be set to i, where 0 < i <= sides" do
        [4, 6, 10].each do |type|
          d = Die.new(sides: type)
          -10.upto(15).each do |v|
            if v < 1 or v > type
              expect { d.set_to v }.to raise_error(ArgumentError)
            else
              d.set_to v
              expect(d.value).to eq v
            end
          end
        end
      end
    end

    describe "#to_str" do
      it "should tell you the die's value" do
        5.times do
          d = Die.new(sides: rand(10)+3)
          expect("#{d}").to eq "[#{d.value}]/d#{d.sides}"
        end
      end
    end

    describe "#to_int" do
      it "returns the value" do
        expect(subject.to_int).to eq subject.value
      end
    end

    describe "<=>" do
      it "compares numeric objects with the die's value" do
        subject.stub(:value => 3)
        expect(subject).to be < 4
        expect(subject).to be > 2.0
      end

      it "compares dice with each other by value" do
        low_d6 = Die.new(:value => 1)
        high_d6 = Die.new(:value => 6)

        expect(low_d6 <=> low_d6).to eq 0
        expect(low_d6 <=> high_d6).to eq -1
        expect(high_d6 <=> low_d6).to eq 1
      end
    end
  end
end
