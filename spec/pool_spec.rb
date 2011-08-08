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
      it "should return an array of dice notation" do
        @mixed.dice.should == ["2d10","d20"]
        @d6.dice.should == ["d6"]
        @d17s.dice.should == ["5d17"]
        Pool.new("d20 2d10").dice.should == ["2d10","d20"]
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
      it "creates genuinely new pools" do
        merge = @d6 + @d17s
        merge.roll
        @d6.results.should == [2]
        @d17s.results.should == [5, 16, 1, 17, 9]
        
      end
      
      it "should alter #dice accordingly" do
        @d6 = Pool.new("d6")
        @d17s = Pool.new("5d17")
        @mixed = Pool.new("2d10 d20")
        (@d6 + @d17s).dice.should == ["d6", "5d17"]
        (@d17s + @d6).dice.should == ["d6", "5d17"]
        (@d17s + @mixed).dice.should == ["2d10","5d17","d20"]
      end
      it "should understand adding a number as looking for a sum result" do
        (@d17s + 5).should == 53
        (@mixed + @d6 + 10).should == 34
      end
      it "should add literal dice arrays as if they were pools" do
        g = @d6 + [Die.new(6,3), Die.new(10, 4)]
        g.results.should == [2, 3, 4]
        g.dice.should == ["2d6", "d10"]
        g.roll
        @d6.results.should == [2]
      end
      it "should reject adding anything else" do
        lambda {@d6 + "foof"}.should raise_error(ArgumentError)
        lambda {@d6 + [Die.new, Object.new]}.should raise_error(ArgumentError)
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
    describe "#highest" do
      it "should return a pool of the highest-value die" do
        @d6.highest.class.should == Pool
        @d6.highest.results.should == [2]
        @d17s.highest.results.should == [17]
        @mixed.highest.results.should == [11]
      end
      it "should return as many items as are specified" do
        @d6.highest(5).results.should == [2]
        @d17s.highest(3).results.should == [17, 16, 9]
        @mixed.highest(2).results.should == [11, 10]
      end
    end
    describe "#lowest" do
      it "should return a pool of the lowest-value die." do
        @d6.lowest.results.should == [2]
        @d17s.lowest.class.should == Pool
        @d17s.lowest.results.should == [1]
        @mixed.lowest.results.should == [1]
      end
      it "should return as many items as are specified" do
          @d6.lowest(5).results.should == [2]
          @d17s.lowest(3).results.should == [1, 5, 9]
          @mixed.lowest(2).results.should == [1, 10]
      end
    end
    describe "#drop_highest" do
      it "should return a new pool missing the highest result" do
        p = @d17s.drop_highest
        p.results.should == [5, 16, 1, 9]
        @d17s.results.should == [5, 16, 1, 17, 9]
      end
      it "should drop as many items as are specified and are possible" do
        p = @d17s.drop_highest(2)
        p.results.should == [5, 1, 9]
        p = @d6.drop_highest(10)
        p.results.should == []
      end
    end
    describe "#drop_lowest" do
      it "should return a pool missing the lowest result" do
        p = @d17s.drop_lowest
        p.results.should == [5, 16, 17, 9]
        @d17s.results.should == [5, 16, 1, 17, 9]
      end
      it "should drop as many items as are specified" do
        p = @d17s.drop_lowest(2)
        p.results.should == [16, 17, 9]
      end
    end
    context "pool has been emptied" do
    end
  end
end