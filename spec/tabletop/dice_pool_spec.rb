require 'spec_helper'

module Tabletop
  describe DicePool do

    let(:d6_set) { DicePool.new("2/6 1/6 3/6 4/6 5/6 6/6") }
    
    describe ".new" do
      context 'when passed a string in d-notation' do
        it "can build a pool of the described dice" do
          p = DicePool.new("2d10 d20")
          expect(p.size).to eq 3
          expect(p[0].sides).to eq 10
          expect(p[1].sides).to eq 10
          expect(p[2].sides).to eq 20
        end

        it 'recognizes fudge dice' do
          expect(DicePool.new("1.dF")[0]).to be_a FudgeDie
        end

        it 'recognizes d66' do
          expect(DicePool.new('1.d66')[0]).to be_a D66
        end

        it 'recognizes d66' do
          expect(DicePool.new('1.d666')[0]).to be_a D666
        end
      end

      it "can accept an array of dice objects" do
        # mostly used internally
        p = DicePool.new([Die.new(value: 1), Die.new(sides: 4)])
        expect(p.size).to eq 2
        expect(p[0].sides).to eq 6
        expect(p[0].value).to eq 1
        expect(p[1].sides).to eq 4
      end
      it "can accept a string describing a specific dice configuration" do
        pool = DicePool.new("1/4 2/6 3/8")
        expect(pool.size).to eq 3
        expect(pool[0].value).to eq 1
        expect(pool[0].sides).to eq 4
        expect(pool[1].value).to eq 2
        expect(pool[1].sides).to eq 6
        expect(pool[2].value).to eq 3
        expect(pool[2].sides).to eq 8
      end
    end
    
    describe "#d_notation" do
      it "should return an array of dice notation" do
        expect(DicePool.new("d20 2dF 2d10").d_notation).to eq ["2d10","d20", "2dF"]
      end
    end
    
    describe "[]" do
      it "should access the objects " do
        d = DicePool.new("1/4")[0]
        expect(d.value).to eq 1
        expect(d.sides).to eq 4
      end
    end
    
    describe "+" do
      context "adding a number" do
        it "should return the pool's sum plus the number" do
          expect((d6_set + 5)).to eq d6_set.sum + 5
        end
      end
      context "adding a randomizer" do
        it "adds to the pool" do
          expect((d6_set + Die.new).size).to eq 7
        end
        it "preserves class" do
          expect((d6_set + FudgeDie.new(value:-1))[-1].value).to eq -1
          expect((d6_set + Coin.new)[-1]).to respond_to :flip
        end
      end
      context "adding another pool" do
        let(:d4_set) { 4.d4 }
        let(:merge) { d6_set+d4_set }
        it "should make a union of the pools" do
          expect(merge.values).to eq d6_set.values + d4_set.values
        end
        it "should make new die objects" do
          die1, die2 = Die.new, Die.new
          merge = DicePool.new([die1])+DicePool.new([die2])
          die1.should_not_receive :roll
          die2.should_not_receive :roll
          merge.roll
        end
        it "should persist die types" do
          expect((DicePool.new("d6")+DicePool.new("dF"))[1]).to be_instance_of(FudgeDie)
          expect((DicePool.new("d6")+DicePool.new([Coin.new]))[1]).to respond_to(:flip)
        end
        it "should alter #dice accordingly" do
          expect((DicePool.new("2d17 d6")+DicePool.new("3d17")).d_notation).to eq ["d6", "5d17"]
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
          expect((p * 5)).to eq (v * 5)
          expect((5 * p)).to eq (5 * v)
        end
      end
    end

    describe "-" do
      context "subtracting a number" do
        it "should return the pool's sum minus the number" do
          expect((d6_set - 1)).to eq 20
        end
      end
    end
    
    describe "#values" do
      it "should be an array of the values of the dice" do
        d6_set.values.each_with_index do |v, i|
          expect(v).to eq d6_set[i].value
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
        d6_set.size.times do |i|
          expect(actual[i].value).to eq d6_set[i].value
          expect(actual[i].sides).to eq d6_set[i].sides
        end
      end

      it "calls roll on its contents" do
        [@d1,@d2,@d3].map { |d| d.should_receive(:roll)}
        @p.roll
      end
      it "can roll only dice less than a certain value" do
        [@d2,@d3].map { |d| d.should_not_receive(:roll)}
        @d1.should_receive(:roll)

        @p.roll(:value_under=>2)
      end
      it "can roll only dice above a certain value" do
        [@d1,@d2].map { |d| d.should_not_receive(:roll)}
        @d3.should_receive(:roll)

        @p.roll(:value_over=>2)
      end
      it "can roll only dice equal to a certain value" do
        [@d1,@d3].map { |d| d.should_not_receive(:roll)}
        @d2.should_receive(:roll)

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
          expect(p.sum).to eq p.values.inject(:+)
        end
      end
      
      it "should be aliased to #to_int" do
        5.times do
          p = 10.d6
          expect(p.to_int).to eq p.sum
        end
      end
    end
    
    describe "<=>" do
      it "should compare the sums of different pools" do
        expect(DicePool.new("1/4 1/4")).to eq DicePool.new("2/6")
        expect(DicePool.new("10/10")).to eq DicePool.new("10/50")
        expect(DicePool.new("3/6")).to be < DicePool.new("4/4")
      end
      
      it "should compare pools to numbers" do
        expect(DicePool.new("4/8 5/10")).to be < 10
        expect(DicePool.new("1/6 1/8")).to eq 2
        expect(DicePool.new("49/50")).to be <= 49
      end
    end
    
    describe "#sets" do
      it "should group dice in sets, by order of height, then width" do
        expect(DicePool.new("9/10 1/10 5/10 4/10 9/10 5/10 7/10 4/10").sets).to eq ["2x9", "2x5", "2x4", "1x7", "1x1"]
      end
    end
    
    describe "#highest" do
      it "should return a pool of the highest-value die" do
        expect(d6_set.highest.values).to eq [6]
      end
      
      it "should return as many items as are specified" do
        expect(d6_set.highest(3).values).to eq [4,5,6]
        expect(d6_set.highest(10).values).to eq [2,1,3,4,5,6]
      end
    end
    
    describe "#lowest" do
      it "should return a pool of the lowest-value die." do
        expect(d6_set.lowest.values).to eq [1]
      end
      
      it "should return as many items as are specified" do
        expect(d6_set.lowest(3).values).to eq [2,1,3]
        expect(d6_set.lowest(10).values).to eq [2,1,3,4,5,6]
      end
    end
    
    describe "#drop_highest" do
      it "should return a new pool missing the highest result" do
        expect(d6_set.drop_highest.values).to eq [2,1,3,4,5]
      end
      
      it "should drop as many items as are specified and are possible" do
        expect(d6_set.drop_highest(3).values).to eq [2,1,3]
        expect(d6_set.drop_highest(10).values).to eq []
      end
    end

    describe "#drop_lowest" do
      it "should return a pool missing the lowest result" do
        expect(d6_set.drop_lowest.values).to eq [2, 3, 4, 5, 6]
      end
      
      it "should drop as many items as are specified and are possible" do
        expect(d6_set.drop_lowest(2).values).to eq [3,4,5,6]
        expect(d6_set.drop_lowest(10).values).to eq []
      end
    end

    describe "#drop" do
      it "should drop any dice of the specified value" do
        ore = DicePool.new("10d10")
        (10..1).each do |i|
          expect(ore.drop(i)).to_not include(i)
        end
      end
    end
    
    context "pool has been emptied" do
    end

  end
end
