require 'spec_helper'
require 'shared_examples_for_randomizers'

require 'tabletop/randomizers/coin'

module Tabletop
  RSpec.describe Coin do
    it_behaves_like 'a randomizer', :flip, [0,1]

    describe "heads?" do
      it "is true if #value is 1" do
        expect(Coin.new(value:1).heads?).to be true
        expect(Coin.new(value:0).heads?).to be false
      end
    end

    describe "#set_to_heads" do
      it "sets #value to 1" do
        expect(Coin.new(value:0).set_to_heads.value).to eq 1
      end
    end

    describe "tails?" do
      it "is true if #value is 0" do
        expect(Coin.new(value:0).tails?).to be true
        expect(Coin.new(value:1).tails?).to be false
      end
    end

    describe "#set_to_tails" do
      it "sets #value to 0" do
        expect(Coin.new(value:1).set_to_tails.value).to eq 0
      end
    end

    describe "#to_s" do
      it "formats as (+) and ( )" do
        expect(Coin.new(value:1).to_s).to eq "(+)"
        expect(Coin.new(value:0).to_s).to eq "( )"
      end
    end
  end
end
