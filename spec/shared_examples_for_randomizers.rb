RSpec.shared_examples_for 'a randomizer' do |randomize_aliases, possible_values|
  let(:some_value) { double }

  describe '#value' do
    before { allow_any_instance_of(described_class).to receive(:valid_value?).and_return(true) }

    it 'can be explicitly set on instantiation with a :value parameter' do
      expect(described_class.new(:value => some_value).value).to be some_value
    end
  end

  describe '#possible_values' do
    let(:enum) { double(:to_a => double(:sample => nil, :include? => true)) }
    it 'is set on initialization and cast to an array' do
      possible_values ||= enum
      randomizer = described_class.new(:possible_values => possible_values)
      expect(randomizer.possible_values).to eq possible_values.to_a
    end
  end

  describe '#valid_value?' do
    let(:answer) { double }
    before(:example) do
      allow(subject).to receive(:possible_values).and_return(double)
    end
    it 'checks if #possible_values includes it' do
      allow(subject.possible_values).to receive(:include?).with(some_value) { answer }

      expect(subject.valid_value?(some_value)).to be answer
    end
  end

  describe '#set_to' do
    context 'when passed an invalid value' do
      before { allow_any_instance_of(described_class).to receive(:valid_value?).and_return(false) }
      it 'raises ArgumentError' do
        expect {subject.set_to 1}.to raise_exception(ArgumentError)
      end
    end
    context 'when passed a valid value' do
      before { allow_any_instance_of(described_class).to receive(:valid_value?).and_return(true) }

      it 'returns an object with that as its #value' do
        expect(subject.set_to(some_value).value).to be some_value
      end
    end
  end

  ([:randomize] + Array(randomize_aliases)).each do |meth|
    describe "##{meth}" do
      before { allow_any_instance_of(described_class).to receive(:valid_value?).and_return(true) }
      it 'returns an object whose #value comes from #sample-ing #possible_values' do
        allow(subject.possible_values).to receive(:sample) { some_value }

        expect(subject.send(meth).value).to be some_value
      end
    end
  end
end
