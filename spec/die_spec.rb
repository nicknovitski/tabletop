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
      it "cannot be 0 or less" do
        lambda { Die.new(0) }.should raise_error(ArgumentError)
        lambda { Die.new(-5) }.should raise_error(ArgumentError)
      end
      it "cannot be a non-integer" do
        lambda { Die.new(0.1) }.should raise_error(ArgumentError)
        lambda { Die.new(5.7694) }.should raise_error(ArgumentError)
        lambda { Die.new("foof") }.should raise_error(ArgumentError)
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
        lambda { Die.new(0.1) }.should raise_error(ArgumentError)
        lambda { Die.new(5.7694) }.should raise_error(ArgumentError)
        lambda { Die.new("foof") }.should raise_error(ArgumentError)
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
    describe "#inspect" do
      before(:each) do
        Random.srand(10)
      end
      it "should be interesting" do
        Die.new.inspect.should == "2 (d6)"
        Die.new.inspect.should == "6 (d6)"
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
        lambda {FudgeDie.new(2)}.should raise_error(ArgumentError)
        lambda {FudgeDie.new(0.6)}.should raise_error(ArgumentError)
        lambda {FudgeDie.new("5")}.should raise_error(ArgumentError)
      end
    end
    describe "#value=" do
      it "cannot be set to anything but -1, 0, or 1" do
        lambda {@fudge.value = 2}.should raise_error(ArgumentError)
        lambda {@fudge.value = 0.6}.should raise_error(ArgumentError)
        lambda {@fudge.value = "5"}.should raise_error(ArgumentError)
        [-1, 0, 1].each do |v|
          @fudge.value = v
        end
      end
    end
    describe "#inspect" do
      it "should look like plusses, minuses and spaces" do
        FudgeDie.new(1).inspect.should == "[+] (dF)"
        FudgeDie.new(0).inspect.should == "[ ] (dF)"
        FudgeDie.new(-1).inspect.should == "[-] (dF)"
      end
    end
  end
end