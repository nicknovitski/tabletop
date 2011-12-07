require 'spec_helper'

module Tabletop
  describe Condition do
    describe "#met_by?" do
      it "it evaluates the block passed on initialization" do
        c = Condition.new do |p|
          p.sum > 7
        end
        c.met_by?(Pool.new("2/6 4/10")).should be_false
        c.met_by?(Pool.new("4/8 4/12")).should be_true
      end
    end
  end
end