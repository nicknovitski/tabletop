require 'spec_helper'

module Tabletop
  describe Pool do

    let(:d6_set) { Pool.new("2/6 1/6 3/6 4/6 5/6 6/6") }
    
    describe ".new" do
      it "can accept a string of d-notation" do
        p = Pool.new("2d10 d20")
        p.length.should == 3
        p[0].sides.should == 10
        p[1].sides.should == 10
        p[2].sides.should == 20
      end
      it "can accept an array of dice objects" do
        # mostly used internally
        p = Pool.new([Die.new(value: 1), Die.new(sides: 4)])
        p.length.should == 2
        p[0].sides.should == 6
        p[0].value.should == 1
        p[1].sides.should == 4
      end
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
        Pool.new("d20 2dF 2d10").dice.should == ["2d10","d20", "2dF"]
      end
    end
    
    describe "[]" do
      it "should access the objects " do
        d = Pool.new("1/4")[0]
        d.value.should == 1
        d.sides.should == 4
      end
    end
    
    describe "+" do
      context "adding a number" do
        it "should return the pool's sum plus the number" do
          p = 5.d6
          (p + 5).should == p.sum + 5
        end
      end
      context "adding another pool" do
        it "should make a union of the pools" do
          a = 5.d6
          b = 4.d4
          merge = a+b
          merge.values.should == a.values+b.values
        end
        it "should make new die objects" do
          a = 5.d6
          b = 4.d4
          merge = a+b
          merge.roll
          merge.values.should_not == a.values + b.values
        end
        it "should persist die types" do
          (Pool.new("d6")+Pool.new("dF"))[1].should be_instance_of(FudgeDie)
          (Pool.new("d6")+Pool.new([Coin.new]))[1].should respond_to(:flip)
        end
        it "should alter #dice accordingly" do
          (Pool.new("2d17 d6")+Pool.new("3d17")).dice.should == ["d6", "5d17"]
        end
      end
      context "adding a literal dice array" do
        it "should make a union as if the array were a Pool"
        it "should make new die objects"
        it "should persist die types"
        it "should alter #dice accordingly"
      end
      context "adding anything else" do
        it "should raise an exception" do
          expect {Pool.new("d6") + "foof"}.to raise_error(ArgumentError)
          expect {Pool.new("d6") + [Die.new, Object.new]}.to raise_error(ArgumentError)
        end
      end
    end
    
    describe "*" do
      it "should multiply by the sum of the pool" do
        (1..10).each do |v|
          p = Pool.new("#{v}/10")
          (p * 5).should == (v * 5)
          (5 * p).should == (5 * v)
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
      it "should return the Pool itself" do
        actual = d6_set.roll
        d6_set.length.times do |i|
          actual[i].value.should == d6_set[i].value
          actual[i].sides.should == d6_set[i].sides
        end
      end
      
      it "calls roll on its contents" do
        d = double("a die")
        d.should_receive(:roll)
        Pool.new([d]).roll
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
        Pool.new("1/4 1/4").should == Pool.new("2/6")
        Pool.new("10/10").should == Pool.new("10/50")
        Pool.new("3/6").should < Pool.new("4/4")
      end
      
      it "should compare pools to numbers" do
        Pool.new("4/8 5/10").should < 10
        Pool.new("1/6 1/8").should == 2
        Pool.new("49/50").should <= 49
      end
    end
    
    describe "#sets" do
      it "should group dice in sets, by order of height, then width" do
        Pool.new("9/10 1/10 5/10 4/10 9/10 5/10 7/10 4/10").sets.should == ["2x9", "2x5", "2x4", "1x7", "1x1"]
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
        ore = Pool.new("10d10")
        (10..1).each do |i|
          ore.drop(i).should_not include(i)
        end
      end
    end
    
    context "pool has been emptied" do
    end

  end
end