require 'spec_helper'

module DicePool
  describe Fixnum do
    describe "#dX" do
      it "generates a pool of the appropriate size and type" do
        roll = 4.d7
        roll.class.should == Pool
        roll.dice.should == ["4d7"]
      end
    end
  end
end