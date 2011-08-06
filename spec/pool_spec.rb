require 'spec_helper'

module DicePool
  describe Pool do
    before :each do
      Random.srand(10)
      @d6 = Pool.new("d6")
      @d17s = Pool.new("5d17")
      @mixed = Pool.new("2d10 d20") 
    end
    describe "#dice" do
      it "knows what dice it has" do
        @mixed.dice.should == "2d10 d20"
        @d6.dice.should == "d6"
        @d17s.dice.should == "5d17"
        Pool.new("d20 2d10").dice.should == "2d10 d20"
      end
    end
    describe "[]" do
      it "should access Die objects" do
        @d6[0].class.should == Die
      end
    end
    describe "+" do
      it "should join Pools into new Pools" do
        merge = @mixed + @d17s
        merge.class == Pool
      end
      it "should join pools without rolling them" do
        merge = @d6 + @d17s
        merge.results.should == [2, 5, 16, 1, 17, 9]
        merge.roll
        merge.results.should == [1, 5, 17, 5, 16, 12]
      end
      it "should alter #dice accordingly" do
        @d6 = Pool.new("d6")
        @d17s = Pool.new("5d17")
        @mixed = Pool.new("2d10 d20")
        (@d6 + @d17s).dice.should == "d6 5d17"
        (@d17s + @d6).dice.should == "d6 5d17"
        (@d17s + @mixed).dice.should == "2d10 5d17 d20"
      end
      it "should understand adding a number as looking for a sum result" do
        (@d17s + 5).should == 53
        (@mixed + @d6 + 10).should == 34
        #(@mixed + 4.5).should == 26.5
      end
      it "should reject adding anything else" do
        lambda {@d6 + "foof"}.should raise_error(ArgumentError)
        lambda {@d6 + [Die.new]}.should raise_error(ArgumentError)
      end
    end
    describe "#results" do
      it "should be an array of random numbers" do
        @d6.results.should == [2]
        @d17s.results.should == [5, 16, 1, 17, 9]
        @mixed.results.should == [10, 1, 11]
      end
    end
    describe "#roll" do
      it "should return the new value" do
        @d6.roll.should == [1]
        @d17s.roll.should == [5, 17, 5, 16, 12]
        @mixed.roll.should == [7, 9, 12]
      end
      it "should store the new values" do
        @d6.roll
        @d6.results.should == [1]
        @d17s.roll
        @d17s.results.should == [5, 17, 5, 16, 12]
        @mixed.roll
        @mixed.results.should == [7, 9, 12]
      end
    end
    describe "#sum" do
      it "should sum the dice values" do
        @d6.sum.should == 2 
        @d17s.sum.should == 48
        @mixed.sum.should == 22
      end
    end
    describe "#sets" do
      it "should list the sets, in order by height and width" do
        ore = Pool.new("10d10")
        ore.sets.should == ["3x9", "2x7","2x5","1x4","1x2","1x1"]
        ore.roll
        ore.sets.should == ["2x10", "2x7", "2x4", "2x2", "1x6", "1x5"]
        ore.roll
        ore.sets.should == ["2x10", "2x9", "2x3", "1x8", "1x7", "1x5", "1x1"]
      end
    end
  end
end