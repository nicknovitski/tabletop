require 'spec_helper.rb'

module DicePool
  describe Die do
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
    describe "#result" do
      before :each do
        Random.srand(10)
      end
      it "should be random on instantiation by default" do 
        d = Die.new
        d.result.should equal(2)
        d = Die.new(10)
        d.result.should equal(5)
        d = Die.new(50)
        d.result.should equal(16)
      end
      it "can be set to a given value on instantiation" do
        Die.new(6, 5).result.should == 5
        Die.new(10, 2).result.should == 2
      end
      it "can be set to a new value" do
        d = Die.new
        d.result = 6
        d.result.should == 6
      end
      it "can only be set to an integer i, where 0 < i <= sides" do
        d = Die.new
        lambda { d.result = 0 }.should raise_error(ArgumentError)
        lambda { d.result = -5 }.should raise_error(ArgumentError)
        lambda { d.result = 7 }.should raise_error(ArgumentError)
        d = Die.new(10)
        d.result = 7
        lambda { d.result = 22 }.should raise_error(ArgumentError)
      end
      it "cannot be a non-integer" do
        lambda { Die.new(0.1) }.should raise_error(ArgumentError)
        lambda { Die.new(5.7694) }.should raise_error(ArgumentError)
        lambda { Die.new("foof") }.should raise_error(ArgumentError)
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
        it "should alter the result appropriately" do
          d = Die.new
          #d.roll # Covered by the initial roll
          d.result.should == 2 
          d.roll
          d.result.should == 6
          d.roll
          d.result.should == 5
          d.roll
          d.result.should == 1
        end
      end
      context "eleven sides" do
        it "should return a random result between 1 and @sides" do 
          d = Die.new(11)
          # d.roll.should == 10 # This result gets swallowed by the init roll
          d.roll.should == 5
          d.roll.should == 1
          d.roll.should == 2
        end
        it "should alter the result appropriately" do
          d = Die.new(11)
          #d.roll # covered by the initial roll
          d.result.should == 10
          d.roll
          d.result.should == 5
          d.roll
          d.result.should == 1
          d.roll
          d.result.should == 2
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
  end
end