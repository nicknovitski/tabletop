require 'spec_helper'
require 'tabletop/d_notation'

module Tabletop
  RSpec.describe Fixnum do
    describe "#d" do
      it "generates a pool of the appropriate size and type" do
        expect(DicePool).to receive(:new).with("1d6").and_return :pool

        expect(1.d(6)).to be :pool
      end
    end

    [4,6,8,10,12,20,30,66,100,666,1000,10000].each do |sides|
      let(:method) { "d#{sides}" }
      describe "#d#{sides}" do
        it 'delegates to #d' do
          expect(DicePool).to receive(:new).with("1#{method}").and_return :pool

          expect(1.send(method.to_sym)).to be :pool
        end
      end
    end
    describe "#dF" do
      it "generates a pool of fudge dice" do
        sotc = 4.dF
        expect(sotc).to be_instance_of(DicePool)
        expect(sotc.all? { |d| d.instance_of?(FudgeDie) }).to be true
        expect(sotc.d_notation).to eq ["4dF"]
      end
    end
  end
end
