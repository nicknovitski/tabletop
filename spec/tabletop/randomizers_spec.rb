require 'spec_helper'
require 'tabletop/randomizers'

shared_examples_for 'a randomizer' do |randomize_aliases, possible_values |
  let(:some_value) { double }
  describe '#random_value' do
    it 'calls #sample on #possible_values' do
      subject.stub_chain(:possible_values, :sample) { some_value }

      expect(subject.random_value).to be some_value
    end
  end

  describe '#value' do
    before { described_class.any_instance.stub(:valid_value? => true) }

    it 'defaults to #random_value' do
      described_class.any_instance.stub(:random_value => double)

      expect(subject.value).to be subject.random_value
    end

    it 'can be explicitly set on instantiation with a :value parameter' do

      expect(described_class.new(:value => some_value).value).to be some_value
    end
  end

  describe '#possible_values' do
    let(:enum) { double(:to_a => double(:sample => nil, :include? => true)) }
    it 'is set on initialization and cast to an array' do
      possible_values ||= enum
      expect(described_class.new(:possible_values => possible_values).possible_values).to eq possible_values.to_a
    end
  end

  describe '#valid_value?' do
    let(:answer) { double }
    before do 
      subject.stub(:possible_values => double)
    end
    it 'checks if #possible_values includes it' do
      subject.possible_values.stub!(:include?).with(some_value) { answer }
      
      expect(subject.valid_value?(some_value)).to be answer
    end
  end

  describe '#value=' do
    context 'when passed an invalid value' do
      before { described_class.any_instance.stub(:valid_value? => false) }
      it 'raises ArgumentError' do
        expect {subject.value = 1}.to raise_exception(ArgumentError)
      end
    end
    context 'when passed a valid value' do
      before { described_class.any_instance.stub(:valid_value? => true) }
      it 'sets #value to that' do
        subject.value = some_value

        expect(subject.value).to be some_value
      end
    end
  end
  
  describe '#set_to' do
    it 'calls #value= with the passed parameter' do
      subject.stub!(:value=).with(some_value)

      subject.set_to(some_value)
    end

    it 'returns self' do
      expect(subject.set_to(1)).to be subject
    end
  end

  ([:randomize] + Array(randomize_aliases)).each do |meth|
    describe "##{meth}" do
      it 'calls #value= with #random_value' do
        subject.stub(:random_value => some_value)

        subject.should_receive(:value=).with(some_value)

        subject.send(meth)
      end

      it 'returns self' do
        expect(subject.send(meth)).to be subject
      end
    end
  end
end
  
module Tabletop
  describe Randomizer do
    subject { Randomizer.new(:possible_values => 1..6) }
    it_behaves_like 'a randomizer'
    let(:some_value) { double }

  end

  describe NumericRandomizer do
    describe '#to_i'
    describe '#<=>'
  end
end
