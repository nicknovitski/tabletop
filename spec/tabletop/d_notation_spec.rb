require 'spec_helper'
require 'tabletop/d_notation'

module Tabletop
  describe Fixnum do
    describe "#dX" do
      it "generates a pool of the appropriate size and type" do
        expect(1.d6).to be_instance_of(DicePool)
        expect(4.d7.d_notation).to eq ["4d7"]
      end
      
      it "raises an exception for invalid method names" do
        expect {10.dthing}.to raise_error(NoMethodError)
      end
      
      it "shows up in respond_to?(:dN)" do
        expect(1).to respond_to(:d50)
        expect(10).to_not respond_to(:dthing)
      end
    end
    describe "#dF" do
      it "generates a pool of fudge dice" do
        sotc = 4.dF
        expect(sotc).to be_instance_of(DicePool)
        expect(sotc.all? { |d| d.instance_of?(FudgeDie) }).to be_true
        expect(sotc.d_notation).to eq ["4dF"]
      end
    end
  end
end
