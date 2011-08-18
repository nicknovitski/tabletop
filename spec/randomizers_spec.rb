require 'spec_helper'

module Tabletop
  describe Die do
    
    before :each do
      @d6_2 = Die.new(6, 2)
      @d6_3 = Die.new(6, 3)
    end
    
    describe "#sides" do
      it "can be accessed" do
        (2..10).each do |i|
          Die.new(i).sides.should == i
        end
      end
      
      it "is 6 by default" do
        Die.new.sides.should == 6
      end
      
      it "cannot be 1 or less" do
        expect { Die.new(0) }.to raise_error(ArgumentError)
        expect { Die.new(1) }.to raise_error(ArgumentError)
        expect { Die.new(-5) }.to raise_error(ArgumentError)
      end
      
      it "cannot be a non-integer" do
        expect { Die.new(0.1) }.to raise_error(ArgumentError)
        expect { Die.new(5.7694) }.to raise_error(ArgumentError)
        expect { Die.new("foof") }.to raise_error(ArgumentError)
      end
    end
    
    describe "#value" do
      it "should be random on instantiation by default" do 
        Random.srand(10)
        Die.new.value.should == 2
        Die.new(10).value.should == 5
        Die.new(50).value.should == 16
      end
      
      it "can be set to a given value on instantiation" do
        Die.new(6, 5).value.should == 5
        Die.new(10, 2).value.should == 2
      end
      
      it "cannot be a non-integer" do
        expect { Die.new(0.1) }.to raise_error(ArgumentError)
        expect { Die.new(5.7694) }.to raise_error(ArgumentError)
        expect { Die.new("foof") }.to raise_error(ArgumentError)
      end
    end
    
    describe "#value=" do
      it "can only be set to an integer i, where 0 < i <= sides" do
        d = Die.new
        lambda { d.value = 0 }.should raise_error(ArgumentError)
        lambda { d.value = -5 }.should raise_error(ArgumentError)
        lambda { d.value = 7 }.should raise_error(ArgumentError)
        d = Die.new(10)
        d.value = 7
        lambda { d.value = 22 }.should raise_error(ArgumentError)
      end
    end
    
    describe "#roll" do
      before(:each) do
        Random.srand(10)
      end
      
      context "six sides" do
        before(:each) do
          @d6 = Die.new #=> 2
        end
        
        it "should return a random result between 1 and @sides" do
          @d6.roll.should == 6
          @d6.roll.should == 5
          @d6.roll.should == 1
        end
        
        it "should alter the value appropriately" do
          10.times do
            @d6.roll.should == @d6.value
          end
        end
      end      
    end
    
    describe "#to_str" do      
      it "should tell you the die's value" do
        5.times do
          d = Die.new(rand(10)+3)
          "#{d}".should == "[#{d.value}]/d#{d.sides}"
        end
      end
    end
    
    describe "#to_int" do
      it "returns the value" do
        d = Die.new
        d.to_int.should == d.value
      end
    end
    
    describe "<=>" do
      it "compares numeric objects with the die's value" do
        (1..10).each do |i|
          (@d6_3 <=> i) == (3 <=> i)
        end
      end
      
      it "compares dice with each other by value" do
        (@d6_3 <=> @d6_2) == (3 <=> 2)
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
        @fudge.sides.should == 3
      end
    end
    
    describe "#value" do
      it "can be set on instantiation" do
        FudgeDie.new(1).value.should == 1
        FudgeDie.new(0).value.should == 0
        FudgeDie.new(-1).value.should == -1
      end
      
      it "is randomly rolled if not set" do
        @fudge.value.should == 0
      end
      
      it "can only be one of either -1, 0, or 1" do
        [-1, 0, 1].each do |v|
          FudgeDie.new(v)
        end
        expect {FudgeDie.new(2)}.to raise_error(ArgumentError)
        expect {FudgeDie.new(0.6)}.to raise_error(ArgumentError)
        expect {FudgeDie.new("5")}.to raise_error(ArgumentError)
      end
    end
    
    describe "#value=" do
      it "cannot be set to anything but -1, 0, or 1" do
        expect {@fudge.value = 2}.to raise_error(ArgumentError)
        expect {@fudge.value = 0.6}.to raise_error(ArgumentError)
        expect {@fudge.value = "5"}.to raise_error(ArgumentError)
        [-1, 0, 1].each do |v|
          @fudge.value = v
        end
      end
    end
    
    describe "#to_s" do
      it "should return cute little dice with symbols" do
        FudgeDie.new(1).to_s.should == "[+]"
        FudgeDie.new(0).to_s.should == "[ ]"
        FudgeDie.new(-1).to_s.should == "[-]"
      end
    end
  end
  
  describe Coin do
    describe "#sides" do
      it {subject.sides.should == 2}
    end
    
    describe "#value" do
      it "can be either 0 or 1" do
        [0, 1].each do |v|
          subject.value = v
        end
      end
      
      it "can't be anything else" do
        expect {subject.value = "a thing"}.to raise_error(ArgumentError)
        expect {subject.value = 2}.to raise_error(ArgumentError)
      end
    end
    
    describe "#flip" do
      it {subject.flip.should be_instance_of(Coin)}
      it "should alias roll" do
        mock(subject).roll
        subject.flip
        # I have to use implicit expectations, because the below code doesn't
        # work in rspec2
        #stub(subject).roll
        #subject.flip
        #subject.should have_received.roll
      end
    end
    
    describe "#to_s" do
      it {Coin.new(1).to_s.should == "(+)"}
      it {Coin.new(0).to_s.should == "( )"}
    end
  end
end