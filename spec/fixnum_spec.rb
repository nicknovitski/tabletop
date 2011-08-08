require 'spec_helper'

module DicePool
  describe Fixnum do
    describe "#dX" do
      it "generates a pool of the appropriate size and type" do
        1.d6.class.should == Pool
        4.d7.dice.should == ["4d7"]
        10.d100.class.should == Pool
      end
    end
    describe "#dF" do
      it "generates a pool of fudge dice" do
        sotc = 4.dF
        sotc.class.should == Pool
        sotc.all? { |d| d.class == FudgeDie }.should be_true
        sotc.dice.should == ["4dF"]
      end
    end
  end
end