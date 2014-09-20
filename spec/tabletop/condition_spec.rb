require 'spec_helper'
require 'tabletop/condition'
require 'tabletop/dice_pool'

module Tabletop
  RSpec.describe Condition do
    describe "#met_by?" do
      it "it evaluates the block passed on initialization" do
        c = Condition.new do |p|
          p.sum > 7
        end
        expect(c.met_by?(DicePool.new("2/6 4/10"))).to be false
        expect(c.met_by?(DicePool.new("4/8 4/12"))).to be true
      end
    end
  end
end
