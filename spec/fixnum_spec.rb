require 'spec_helper'

module Tabletop
  describe Fixnum do
    describe "#dX" do
      it "generates a pool of the appropriate size and type" do
        1.d6.should be_instance_of(DicePool)
        4.d7.d_notation.should == ["4d7"]
      end
      
      it "raises an exception for invalid method names" do
        expect {10.dthing}.to raise_error(NoMethodError)
      end
      
      it "shows up in respond_to?(:dN)" do
        1.should respond_to(:d50)
        10.should_not respond_to(:dthing)
      end
    end
    describe "#dF" do
      it "generates a pool of fudge dice" do
        sotc = 4.dF
        sotc.should be_instance_of(DicePool)
        sotc.all? { |d| d.instance_of?(FudgeDie) }.should be_true
        sotc.d_notation.should == ["4dF"]
      end
    end
  end
end