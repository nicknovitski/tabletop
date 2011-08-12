require 'spec_helper'

module Tabletop
  describe Die do
    before :each do
      @d6_2 = Die.new(6, 2)
      @d6_3 = Die.new(6, 3)
    end
    describe "#sides" do
      it "can be accessed" do
        d = Die.new(6)
        d.sides.should == 6
        d = Die.new(20)
        d.sides.should == 20
        d = Die.new(7)
        d.sides.should equal(7)
      end
      it "is 6 by default" do
        d = Die.new
        d.sides.should equal(6)
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
      before :each do
        Random.srand(10)
      end
      it "should be random on instantiation by default" do 
        d = Die.new
        d.value.should equal(2)
        d = Die.new(10)
        d.value.should equal(5)
        d = Die.new(50)
        d.value.should equal(16)
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
        it "should return a random result between 1 and @sides" do
          d = Die.new
          #d.roll.should == 2 # This result gets swallowed by the init roll
          d.roll.should == 6
          d.roll.should == 5
          d.roll.should == 1
        end
        it "should alter the value appropriately" do
          d = Die.new
          #d.roll # Covered by the initial roll
          d.value.should == 2 
          d.roll
          d.value.should == 6
          d.roll
          d.value.should == 5
          d.roll
          d.value.should == 1
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
        (@d6_3 < 4).should be_true
        (@d6_3 < 2).should be_false
        (@d6_3 > 2).should be_true
        (@d6_3 > 4).should be_false
        (@d6_3 >= 3).should be_true
        (@d6_3 >= 10).should be_false
        (@d6_3 <= 3).should be_true
        (@d6_3 <= 2).should be_false
        (@d6_3 == 3).should be_true
        (@d6_3 == 6).should be_false
      end
      it "compares dice with each other by value" do
        (@d6_3 > @d6_2).should be_true
        (@d6_3 < @d6_2).should be_false
        (@d6_2 < @d6_3).should be_true
        (@d6_2 > @d6_3).should be_false
        (@d6_3 == @d6_2).should be_false
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
        @fudge.value = 1
        @fudge.value.should == 1
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