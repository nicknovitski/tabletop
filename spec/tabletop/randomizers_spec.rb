require 'spec_helper'

module Tabletop
  describe Die do
    before :each do
      @d6_2 = Die.new(value: 2)
      @d6_3 = Die.new(value: 3)
    end

    describe ".new_from_string" do
      it "expects a string in the format 'n/o', where n and o are integers" do
        d = Die.new_from_string('4/5')
 expect(       d.value).to eq 4
        expect(d.sides).to eq 5
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
      it "should be random on instantiation by default" do 
        Random.srand(10)
        expect(Die.new.value).to eq 5
        expect(Die.new(sides: 10).value).to eq 1
        expect(Die.new(sides: 50, value: nil).value).to eq 32
      end
      
      it "can be set to a given value on instantiation" do
        expect(Die.new(value: 5).value).to eq 5
        expect(Die.new(sides: 10, value: 2).value).to eq 2
      end
      
      it "is cast as an integer" do
        expect { Die.new(value: []) }.to raise_error(TypeError)
        expect(Die.new(value: 5.7694).value).to eq 5
        expect { Die.new(value: "foof")}.to raise_error(ArgumentError)
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
    
    describe "#roll" do
      before(:each) do
        Random.srand(10)
      end
      
      context "a die with six sides" do
        before(:each) do
          @d6 = Die.new
        end
        
        it "should return a random result between 1 and @sides" do
          expect(@d6.roll).to eq 1
          expect(@d6.roll).to eq 4
          expect(@d6.roll).to eq 5
        end
        
        it "should alter the value appropriately" do
          10.times do
            expect(@d6.roll).to eq @d6.value
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
        d = Die.new
        expect(d.to_int).to eq d.value
      end
    end
    
    describe "<=>" do
      it "compares numeric objects with the die's value" do
        (1..10).each do |i|
          expect((@d6_3 <=> i)).to eq (3 <=> i)
        end
      end
      
      it "compares dice with each other by value" do
        expect((@d6_3 <=> @d6_2)).to eq (3 <=> 2)
      end
    end
  end
  
  describe FudgeDie do
    before(:each) do
      Random.srand(10)
      @fudge = FudgeDie.new
    end
    
    describe "#sides" do
      it "is always 3" do
        expect(@fudge.sides).to eq 3
      end
    end
    
    describe "#value" do
      it "can be set on instantiation" do
        [-1, 0, 1].each do |v|
          expect(FudgeDie.new(value:v).value).to eq v
        end
      end
      
      it "is randomly rolled if not set" do
        expect(@fudge.value).to eq 1
      end

      it "can only be -1, 0 or 1" do
        expect {FudgeDie.new(value:2)}.to raise_error(ArgumentError)
        expect {FudgeDie.new(value:"-5")}.to raise_error(ArgumentError)
      end
    end
    
    describe "#set_to" do
      it "can be passed -1, 0, or 1" do
        [-1, 0, 1].each do |v|
          @fudge.set_to v
          expect(@fudge.value).to eq v
        end
      end
      it "cannot be set to anything else" do
        expect {@fudge.set_to 2}.to raise_error(ArgumentError)
        expect {@fudge.set_to "-5"}.to raise_error(ArgumentError)
      end
    end
    
    describe "#to_s" do
      it "should return cute little dice with symbols" do
        expect(FudgeDie.new(value:1).to_s).to eq "[+]"
        expect(FudgeDie.new(value:0).to_s).to eq "[ ]"
        expect(FudgeDie.new(value:-1).to_s).to eq "[-]"
      end
    end
  end
  
  describe Coin do

    describe "#sides" do
      it 'is 2' do
        expect(subject.sides).to eq 2
      end
    end
    
    describe "#set_to" do
      it "can be either 0 or 1" do
        [0, 1].each do |v|
          subject.set_to v
        end
      end
      
      it "can't be anything else" do
        expect {subject.set_to "2"}.to raise_error(ArgumentError)
        expect {subject.set_to -1.6}.to raise_error(ArgumentError)
      end
    end

    describe "heads?" do
      it "is true if #value is 1" do
        expect(Coin.new(value:1).heads?).to be_true
        expect(Coin.new(value:0).heads?).to be_false
      end
    end
    
    describe "#set_to_heads" do
      it "sets #value to 1" do
        expect(Coin.new(value:0).set_to_heads.value).to eq 1
      end
    end

    describe "tails?" do
      it "is true if #value is 0" do
        expect(Coin.new(value:0).tails?).to be_true
        expect(Coin.new(value:1).tails?).to be_false
      end
    end

    describe "#set_to_tails" do
      it "sets #value to 0" do
        expect(Coin.new(value:1).set_to_tails.value).to eq 0
      end
    end
    
    describe "#flip" do
      it "should alias roll"
    end
    
    describe "#to_s" do
      it "formats as (+) and ( )" do
        expect(Coin.new(value:1).to_s).to eq "(+)"
        expect(Coin.new(value:0).to_s).to eq "( )"
      end
    end
  end
end
