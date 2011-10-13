require 'spec_helper'

module Tabletop
  describe Pool do
    before :each do
      Random.srand(10)
      @d6 = Pool.new("d6")
      @d17s = Pool.new("5d17")
      @mixed = Pool.new("2d10 d20") 
      @fudge = Pool.new("3dF")
    end
    
    describe ".new" do
      it "can accept a string of d-notation"
      it "can accept an array of dice objects"
      it "can accept a string describing a specific dice configuration" do
        pool = Pool.new("1/4 2/6 3/8")
        pool.length.should == 3
        pool[0].value.should == 1
        pool[0].sides.should == 4
        pool[1].value.should == 2
        pool[1].sides.should == 6
        pool[2].value.should == 3
        pool[2].sides.should == 8
      end
    end
    
    describe "#dice" do
      it "should return an array of dice notation" do
        @mixed.dice.should == ["2d10","d20"]
        @d6.dice.should == ["d6"]
        @d17s.dice.should == ["5d17"]
        @fudge.dice.should == ["3dF"]
        Pool.new("d20 2dF 2d10").dice.should == ["2d10","d20", "2dF"]
      end
    end
    
    describe "[]" do
      it "should access Die objects" do
        @d6[0].should be_instance_of(Die)
        @fudge[0].should be_instance_of(FudgeDie)
      end
    end
    
    describe "+" do
      it "should join Pools into new Pools" do
        (@mixed + @d17s).should be_instance_of(Pool)
        (@d6 + @fudge).should be_instance_of(Pool)
      end
      
      it "should persist die types" do
        (@d6 + @fudge)[1].should be_instance_of(FudgeDie)
      end
      
      it "should join pools without rolling them" do
        merge = @d6 + @d17s
        merge.values.should == [2, 5, 16, 1, 17, 9]
        merge.roll
        merge.values.should == [4, 17, 5, 16, 12, 12]
      end
      
      it "creates genuinely new pools" do
        merge = @d6 + @d17s
        merge.roll
        @d6.values.should == [2]
        @d17s.values.should == [5, 16, 1, 17, 9]
      end
      
      it "should alter #dice accordingly" do
        @d6 = Pool.new("d6")
        @d17s = Pool.new("5d17")
        @mixed = Pool.new("2d10 d20")
        (@d6 + @d17s).dice.should == ["d6", "5d17"]
        (@d17s + @d6).dice.should == ["d6", "5d17"]
        (@d17s + @mixed).dice.should == ["2d10","5d17","d20"]
        (@mixed + @fudge).dice.should == ["2d10", "d20", "3dF"]
      end
      
      it "should understand adding a number as looking for a sum result" do
        (@d17s + 5).should == 53
        (@mixed + @d6 + 10).should == 34
        (@fudge + 3).should == 2
      end
      
      it "should add literal dice arrays as if they were pools" do
        g = @d6 + [Die.new(6,3), Die.new(10, 4)]
        g.values.should == [2, 3, 4]
        g.dice.should == ["2d6", "d10"]
        g.roll
        @d6.values.should == [2]
      end
      
      it "should reject adding anything else" do
        expect {@d6 + "foof"}.to raise_error(ArgumentError)
        expect {@d6 + [Die.new, Object.new]}.to raise_error(ArgumentError)
      end
    end
    
    describe "*" do
      it "should multiply by the sum of the pool" do
        (1..10).each do |v|
          p = Pool.new([Die.new(10, v)])
          (p * 5).should == (v * 5)
          (5 * p).should == (5 * v)
        end
      end
    end
    
    describe "#values" do
      it "should be an array of random numbers" do
        @d6.values.should == [2]
        @d17s.values.should == [5, 16, 1, 17, 9]
        @mixed.values.should == [10, 1, 11]
      end
    end
    
    describe "#roll" do
      it "should return the Pool itself" do
        @d6.roll.length.should == @d6.length
        @d6.roll.should be_instance_of(Pool)
      end
      
      it "should store the new values" do
        @d6.roll
        @d6.values.should == [4]
        @d17s.roll
        @d17s.values.should == [17, 5, 16, 12, 12]
        @mixed.roll
        @mixed.values.should == [2, 9, 5]
      end
      it "can roll only dice below a certain value"
      it "can roll only dice above a certain value"
      it "can roll only dice equal to a certain value"
    end
    
    describe "#sum" do
      it "should sum the dice values" do
        5.times do
          p = 10.d6
          p.sum.should == p.values.inject(:+)
        end
      end
      
      it "should be aliased to #to_int" do
        5.times do
          p = 10.d6
          p.to_int.should == p.sum
        end
      end
    end
    
    describe "<=>" do
      it "should compare the sums of different pools" do
        @d17s.should >= @d6
        @d6.should < Pool.new([Die.new(4, 4)])
      end
      
      it "should compare pools to numbers" do
        @d6.should < 10
        @d6.should == 2
        @d17s.should <= 49
      end
    end
    
    describe "#sets" do
      it "should list the sets, in order by height and width" do
        ore = Pool.new("10d10")
        ore.sets.should == ["2x9", "2x5", "2x4", "2x2", "1x7", "1x1"]
        ore.roll
        ore.sets.should == ["3x10", "2x7", "1x6", "1x5", "1x4", "1x3", "1x2"]
        ore.roll
        ore.sets.should == ["3x9", "2x8", "2x7", "1x10", "1x3", "1x1"]
      end
    end
    
    describe "#highest" do
      it "should return a pool of the highest-value die" do
        @d6.highest.should be_instance_of(Pool)
        @d6.highest.values.should == [2]
        @d17s.highest.values.should == [17]
        @mixed.highest.values.should == [11]
      end
      
      it "should return as many items as are specified" do
        @d6.highest(5).values.should == [2]
        @d17s.highest(3).values.should == [17, 16, 9]
        @mixed.highest(2).values.should == [11, 10]
      end
    end
    
    describe "#lowest" do
      it "should return a pool of the lowest-value die." do
        @d6.lowest.values.should == [2]
        @d17s.lowest.should be_instance_of(Pool)
        @d17s.lowest.values.should == [1]
        @mixed.lowest.values.should == [1]
      end
      
      it "should return as many items as are specified" do
          @d6.lowest(5).values.should == [2]
          @d17s.lowest(3).values.should == [1, 5, 9]
          @mixed.lowest(2).values.should == [1, 10]
      end
    end
    
    describe "#drop_highest" do
      it "should return a new pool missing the highest result" do
        p = @d17s.drop_highest
        p.values.should == [5, 16, 1, 9]
        @d17s.values.should == [5, 16, 1, 17, 9]
      end
      
      it "should drop as many items as are specified and are possible" do
        p = @d17s.drop_highest(2)
        p.values.should == [5, 1, 9]
        p = @d6.drop_highest(10)
        p.values.should == []
      end
    end

    describe "#drop_lowest" do
      it "should return a pool missing the lowest result" do
        p = @d17s.drop_lowest
        p.values.should == [5, 16, 17, 9]
        @d17s.values.should == [5, 16, 1, 17, 9]
      end
      
      it "should drop as many items as are specified" do
        p = @d17s.drop_lowest(2)
        p.values.should == [16, 17, 9]
      end
    end

    describe "#drop" do
      it "should drop any dice of the specified value" do
        ore = Pool.new("10d10")
        ore.values.should == [4, 1, 5, 7, 9, 2, 9, 5, 2, 4]
        at_least_two = ore.drop(1)
        at_least_two.values.should == [4, 5, 7, 9, 2, 9, 5, 2, 4]
        at_least_three = ore.drop([1,2])
        at_least_three.values.should == [4, 5, 7, 9, 9, 5, 4]
      end
    end
    
    context "pool has been emptied" do
    end

  end
end