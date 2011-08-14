require 'spec_helper'

module Tabletop
  describe TokenStack do

    describe "#count" do
      it {subject.count.should == 1}
      it "can be set on instantiation" do
        (1..5).each do |v|
          TokenStack.new(v).count.should == v
        end
      end
    end

    describe "#add" do

      context "when called without arguments" do
        it "increases the count by 1" do
          subject.add
          subject.count.should == 2
        end
      end

      context "when called with one argument" do
        it "increases the count by that argument" do
          subject.add(2)
          subject.count.should == 3
          (1..5).each do |i|
            expect {
              subject.add(i)
            }.to change{subject.count}.by(i)
          end
        end
        
        it "does not accept non-integers" do
          expect { subject.add(0.1) }.to raise_error(ArgumentError)
        end
        
        it "does not accept arguments < 1" do
          expect { subject.add(0) }.to raise_error(ArgumentError)
          expect { subject.add(-1) }.to raise_error(ArgumentError)
          subject.add(1)
        end
      end
    end
    describe "#remove" do
      context "when called without arguments" do
        it "decreases the count by 1" do
          subject.remove
          subject.count.should == 0
        end
      end

      context "when called with one argument" do
        it "decreases the count by that argument" do
          (1..5).each do |i|
            s = TokenStack.new(5)
            expect {s.remove(i)}.to change{s.count}.from(5).to(5-i)
          end
        end
        
        it "does not accept non-integers" do
          expect { subject.remove(0.1) }.to raise_error(ArgumentError)
        end
        
        it "does not accept arguments < 1" do
          expect { subject.remove(0) }.to raise_error(ArgumentError)
          expect { subject.remove(-1) }.to raise_error(ArgumentError)
          subject.remove(1)
        end
        
        it "raises an error when trying to remove too many" do
          expect { subject.remove(2) }.to raise_error(
            NotEnoughTokensError,
            /tried to remove 2 tokens from a stack with 1 token/)
          expect { TokenStack.new(2).remove(3) }.to raise_error(
            NotEnoughTokensError,
            /tried to remove 3 tokens from a stack with 2 tokens/)
          expect { TokenStack.new(0).remove(1) }.to raise_error(
            NotEnoughTokensError,
            /tried to remove 1 token from a stack with no tokens/)
        end
      end
    end
    describe "#move" do
      before :each do
        @a = TokenStack.new(10)
        @b = TokenStack.new(10)
      end
      it "removes tokens from the receiving stack"
      it "adds tokens to the argument stack"
    end
  end
end