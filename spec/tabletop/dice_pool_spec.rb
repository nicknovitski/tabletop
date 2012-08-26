require 'spec_helper'

module Tabletop
  describe DicePool do

    let(:d6_set) { DicePool.new("2/6 1/6 3/6 4/6 5/6 6/6") }
    
    describe ".new" do
      it "can accept a string of d-notation" do
        p = DicePool.new("2d10 d20")
        p.length.should == 3
        p[0].sides.should == 10
        p[1].sides.should == 10
        p[2].sides.should == 20
      end
      it "can accept an array of dice objects" do
        # mostly used internally
        p = DicePool.new([Die.new(value: 1), Die.new(sides: 4)])
        p.length.should == 2
        p[0].sides.should == 6
        p[0].value.should == 1
        p[1].sides.should == 4
      end
      it "can accept a string describing a specific dice configuration" do
        pool = DicePool.new("1/4 2/6 3/8")
        pool.length.should == 3
        pool[0].value.should == 1
        pool[0].sides.should == 4
        pool[1].value.should == 2
        pool[1].sides.should == 6
        pool[2].value.should == 3
        pool[2].sides.should == 8
      end
    end
    
    describe "#d_notation" do
      it "should return an array of dice notation" do
        DicePool.new("d20 2dF 2d10").d_notation.should == ["2d10","d20", "2dF"]
      end
    end
    
    describe "[]" do
      it "should access the objects " do
        d = DicePool.new("1/4")[0]
        d.value.should == 1
        d.sides.should == 4
      end
    end
    
    describe "+" do
      context "adding a number" do
        it "should return the pool's sum plus the number" do
          (d6_set + 5).should == d6_set.sum + 5
        end
      end
      context "adding a randomizer" do
        it "adds to the pool" do
          (d6_set + Die.new).length.should == 7
        end
        it "preserves class" do
          (d6_set + FudgeDie.new(value:-1))[-1].value.should == -1
          (d6_set + Coin.new)[-1].should respond_to :flip
        end
      end
      context "adding another pool" do
        let(:d4_set) { 4.d4 }
        let(:merge) { d6_set+d4_set }
        it "should make a union of the pools" do
          merge.values.should == d6_set.values + d4_set.values
        end
        it "should make new die objects" do
          die1, die2 = Die.new, Die.new
          merge = DicePool.new([die1])+DicePool.new([die2])
          die1.should_not_receive :roll
          die2.should_not_receive :roll
          merge.roll
        end
        it "should persist die types" do
          (DicePool.new("d6")+DicePool.new("dF"))[1].should be_instance_of(FudgeDie)
          (DicePool.new("d6")+DicePool.new([Coin.new]))[1].should respond_to(:flip)
        end
        it "should alter #dice accordingly" do
          (DicePool.new("2d17 d6")+DicePool.new("3d17")).d_notation.should == ["d6", "5d17"]
        end
      end
      context "adding anything else" do
        it "should raise an exception" do
          expect {DicePool.new("d6") + "foof"}.to raise_error(ArgumentError)
          expect {DicePool.new("d6") + [Die.new, Object.new]}.to raise_error(ArgumentError)
        end
      end
    end
    
    describe "*" do
      it "should multiply by the sum of the pool" do
        (1..10).each do |v|
          p = DicePool.new("#{v}/10")
          (p * 5).should == (v * 5)
          (5 * p).should == (5 * v)
        end
      end
    end

    describe "-" do
      context "subtracting a number" do
        it "should return the pool's sum minus the number" do
          (d6_set - 1).should == 20
        end
      end
    end
    
    describe "#values" do
      it "should be an array of the values of the dice" do
        d6_set.values.each_with_index do |v, i|
          v.should == d6_set[i].value
        end
      end
    end
    
    describe "#roll" do
      before :each do
        @d1, @d2, @d3= double("a die"), double("a die"), double("a die")
        @d1.stub(:value).and_return(1)
        @d2.stub(:value).and_return(2)
        @d3.stub(:value).and_return(3)
        @p = DicePool.new([@d1, @d2, @d3])
        end
      it "should return the Pool itself" do
        actual = d6_set.roll
        d6_set.length.times do |i|
          actual[i].value.should == d6_set[i].value
          actual[i].sides.should == d6_set[i].sides
        end
      end

      it "calls roll on its contents" do
        @d1.should_receive(:roll)
        @d2.should_receive(:roll)
        @d3.should_receive(:roll)
        @p.roll
      end
      it "can roll only dice less than a certain value" do
        @d1.should_receive(:roll)
        @d2.should_not_receive(:roll)
        @d3.should_not_receive(:roll)

        @p.roll(:value_under=>2)
      end
      it "can roll only dice above a certain value" do
        @d1.should_not_receive(:roll)
        @d2.should_not_receive(:roll)
        @d3.should_receive(:roll)

        @p.roll(:value_over=>2)
      end
      it "can roll only dice equal to a certain value" do
        @d1.should_not_receive(:roll)
        @d2.should_receive(:roll)
        @d3.should_not_receive(:roll)

        @p.roll(:value_equals=>2)
      end
    end

    describe "#roll_if" do
      before :each do
        @d1 = double("a die")
        @d2 = double("a die")
      end
      it "rolls dice when the block returns true" do
        @d1.should_receive(:roll)
        DicePool.new([@d1]).roll_if {|die| true}
      end
      it "doesn't roll dice when the block returns false" do
        @d1.should_not_receive(:roll)
        DicePool.new([@d1]).roll_if {|die| false}
      end
      it "rolls dice that satisfy the block condition" do
        @d1.stub(:sides).and_return(3)
        @d2.stub(:sides).and_return(4)

        @d1.should_not_receive(:roll)
        @d2.should_receive(:roll)
        DicePool.new([@d1, @d2]).roll_if {|die| die.sides > 3}
      end
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
        DicePool.new("1/4 1/4").should == DicePool.new("2/6")
        DicePool.new("10/10").should == DicePool.new("10/50")
        DicePool.new("3/6").should < DicePool.new("4/4")
      end
      
      it "should compare pools to numbers" do
        DicePool.new("4/8 5/10").should < 10
        DicePool.new("1/6 1/8").should == 2
        DicePool.new("49/50").should <= 49
      end
    end
    
    describe "#sets" do
      it "should group dice in sets, by order of height, then width" do
        DicePool.new("9/10 1/10 5/10 4/10 9/10 5/10 7/10 4/10").sets.should == ["2x9", "2x5", "2x4", "1x7", "1x1"]
      end
    end
    
    describe "#highest" do
      it "should return a pool of the highest-value die" do
        d6_set.highest.values.should == [6]
      end
      
      it "should return as many items as are specified" do
        d6_set.highest(3).values.should == [4,5,6]
        d6_set.highest(10).values.should == [2,1,3,4,5,6]
      end
    end
    
    describe "#lowest" do
      it "should return a pool of the lowest-value die." do
        d6_set.lowest.values.should == [1]
      end
      
      it "should return as many items as are specified" do
        d6_set.lowest(3).values.should == [2,1,3]
        d6_set.lowest(10).values.should == [2,1,3,4,5,6]
      end
    end
    
    describe "#drop_highest" do
      it "should return a new pool missing the highest result" do
        d6_set.drop_highest.values.should == [2,1,3,4,5]
      end
      
      it "should drop as many items as are specified and are possible" do
        d6_set.drop_highest(3).values.should == [2,1,3]
        d6_set.drop_highest(10).values.should == []
      end
    end

    describe "#drop_lowest" do
      it "should return a pool missing the lowest result" do
        d6_set.drop_lowest.values.should == [2, 3, 4, 5, 6]
      end
      
      it "should drop as many items as are specified and are possible" do
        d6_set.drop_lowest(2).values.should == [3,4,5,6]
        d6_set.drop_lowest(10).values.should == []
      end
    end

    describe "#drop" do
      it "should drop any dice of the specified value" do
        ore = DicePool.new("10d10")
        (10..1).each do |i|
          ore.drop(i).should_not include(i)
        end
      end
    end
    
    context "pool has been emptied" do
    end

  end
end