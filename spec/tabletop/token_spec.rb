require 'spec_helper'

module Tabletop
  RSpec.describe TokenStack do

    describe "#count" do
      it 'defaults to 1' do # uhhhh why? 
        expect(subject.count).to eq 1
      end
      
      it "can be set on instantiation" do
        (1..5).each do |v|
          expect(TokenStack.new(v).count).to eq v
        end
      end
      
      it "is called when stacks are compared to numbers" do
        (1..5).each do |v|
          s = TokenStack.new(v)
          expect(s).to eq v
          expect(s).to be >= v-1
          expect(s).to be <= v+1
        end
      end
    end

    describe "#add" do

      context "when called without arguments" do
        it "increases the count by 1" do
          subject.add
          expect(subject.count).to eq 2
        end
      end

      context "when called with one argument" do
        it "increases the count by that argument" do
          subject.add(2)
          expect(subject.count).to eq 3
          (1..5).each do |i|
            expect {
              subject.add(i)
            }.to change{subject.count}.by(i)
          end
        end
        
        it "casts arguments to integers" do
          subject.add(3.5)
          expect(subject.count).to eq 4
          expect { subject.add(Object) }.to raise_error(ArgumentError)
        end
        
        it "does not accept arguments < 0" do
          expect { subject.add(-1) }.to raise_error(ArgumentError)
        end
      end
    end
    describe "#remove" do
      context "when called without arguments" do
        it "decreases the count by 1" do
          subject.remove
          expect(subject.count).to eq 0
        end
      end

      context "when called with one argument" do
        it "decreases the count by that argument" do
          (1..5).each do |i|
            s = TokenStack.new(5)
            expect {s.remove(i)}.to change{s.count}.by(-i)
          end
        end
        
        it "casts arguments to integers" do
          subject.count = 2
          subject.remove(Math::E)
          expect(subject.count).to eq 0
          expect { subject.remove(Object) }.to raise_error(ArgumentError)
        end
        
        it "does not accept arguments < 0" do
          expect { subject.remove(-1) }.to raise_error(ArgumentError)
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
        @a = TokenStack.new
        @b = TokenStack.new
      end
      it "removes tokens from the receiving stack" do
        (1..10).each do |v|
          @a.add(v)
          expect {@a.move(v, :to =>@b)}.to change{@a.count}.by(-v)
        end
      end
      it "adds tokens to the stack passed as the :to argument" do
        (1..10).each do |v|
          @a.add(v)
          expect {@a.move(v, :to =>@b)}.to change{@b.count}.by(v)
        end
      end
      it "doesn't move any tokens if :to isn't a TokenStack" do
        expect {@a.move(1, :to => [])}.to raise_error ArgumentError
        expect(@a.count).to eq 1
      end
      it "doesn't move any tokens if no :to option is passed" do
        expect {@a.move(1)}.to raise_error ArgumentError
        expect(@a.count).to eq 1
      end
      it "doesn't move any tokens if there aren't enough tokens to move" do
        expect {@a.move(2, :to => @b)}.to raise_error NotEnoughTokensError
        expect(@a.count).to eq 1
        expect(@b.count).to eq 1
      end
    end

    context "with a maximum set" do
      describe "#max" do
        it "can be set on instantiation" do
          2.upto(5) do |v|
            s = TokenStack.new(1, max: v)
            expect(s.max).to eq v
          end
        end
      end
      describe "#count=" do
        it "cannot be set higher than the current maximum" do
          2.upto(5) do |v|
            s = TokenStack.new(1, max: v)
            s.count = v
            expect{s.count = v+1}.to raise_error ExceedMaxTokensError 
          end
        end
      end
      describe "#add" do
        it "cannot go above the maximum" do
          s = TokenStack.new(1, max: 1)
          expect{s.add(1)}.to raise_error ExceedMaxTokensError
          s.max = 5
          s.add(1)
          expect{s.add(5)}.to raise_error ExceedMaxTokensError
        end
        it "knows to round down decimals" do
          subject.max = 2
          subject.add(1.8)
        end
      end
      describe "#refresh" do
        it "sets the count to the maximum" do
          2.upto(5) do |v|
            s = TokenStack.new(1, max: v)
            s.refresh
            expect(s.count).to eq v
          end
        end
      end
    end
    context "with no maximum set" do
      describe "#max" do
        it 'is nil' do
          expect(subject.max).to be_nil
        end
      end
      describe "#refresh" do
        it "pretends it doesn't exist" do
          expect{ subject.refresh }.to raise_error NoMethodError
        end
      end
    end
  end
end
