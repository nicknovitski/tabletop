require 'spec_helper'

module Tabletop
  describe Fixnum do
    describe "#dX" do
      it "generates a pool of the appropriate size and type" do
        1.d6.should be_instance_of(Pool)
        4.d7.dice.should == ["4d7"]
        10.d100.should be_instance_of(Pool)
      end
      
      it "shows up in respond_to?(:dN)" do
        1.respond_to?(:d50).should be_true
      end
    end
    describe "#dF" do
      it "generates a pool of fudge dice" do
        sotc = 4.dF
        sotc.should be_instance_of(Pool)
        sotc.all? { |d| d.instance_of?(FudgeDie) }.should be_true
        sotc.dice.should == ["4dF"]
      end
    end
  end
end