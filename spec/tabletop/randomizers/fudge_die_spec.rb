require 'spec_helper'
require 'shared_examples_for_randomizers'

require 'tabletop/randomizers/fudge_die'

module Tabletop
RSpec.describe FudgeDie do
    it_behaves_like 'a randomizer', :roll, [-1,0,1]

    describe "#sides" do
      it "is always 3" do
        expect(subject.sides).to eq 3
      end
    end

    describe "#to_s" do
      it "should return cute little dice with symbols" do

        expect(FudgeDie.new(value:1).to_s).to eq "[+]"
        expect(FudgeDie.new(value:0).to_s).to eq "[ ]"
        expect(FudgeDie.new(value:-1).to_s).to eq "[-]"
      end
    end
  end
end
