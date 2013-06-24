require 'spec_helper'
require_relative 'randomizer_spec'

require 'tabletop/randomizers/coin'

module Tabletop
  describe Coin do
    it_behaves_like 'a randomizer', :flip, [0,1]

    describe "heads?" do
      it "is true if #value is 1" do
        expect(Coin.new(value:1).heads?).to be_true
        expect(Coin.new(value:0).heads?).to be_false
      end
    end

    describe "#set_to_heads" do
      it "sets #value to 1" do
        expect(Coin.new(value:0).set_to_heads.value).to eq 1
      end
    end

    describe "tails?" do
      it "is true if #value is 0" do
        expect(Coin.new(value:0).tails?).to be_true
        expect(Coin.new(value:1).tails?).to be_false
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