RSpec.shared_examples_for 'a randomizer' do |randomize_aliases, possible_values |
  let(:some_value) { double }
  describe '#random_value' do
    it 'calls #sample on #possible_values' do
      allow(subject).to receive_message_chain(:possible_values, :sample) { some_value }

      expect(subject.random_value).to be some_value
    end
  end

  describe '#value' do
    before { allow_any_instance_of(described_class).to receive(:valid_value?).and_return(true) }

    it 'defaults to #random_value' do
      allow_any_instance_of(described_class).to receive(:random_value).and_return(double)

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
      allow(subject).to receive(:possible_values).and_return(double)
    end
    it 'checks if #possible_values includes it' do
      allow(subject.possible_values).to receive(:include?).with(some_value) { answer }

      expect(subject.valid_value?(some_value)).to be answer
    end
  end

  describe '#value=' do
    context 'when passed an invalid value' do
      before { allow_any_instance_of(described_class).to receive(:valid_value?).and_return(false) }
      it 'raises ArgumentError' do
        expect {subject.value = 1}.to raise_exception(ArgumentError)
      end
    end
    context 'when passed a valid value' do
      before { allow_any_instance_of(described_class).to receive(:valid_value?).and_return(true) }
      it 'sets #value to that' do
        subject.value = some_value

        expect(subject.value).to be some_value
      end
    end
  end

  describe '#set_to' do
    it 'calls #value= with the passed parameter' do
      allow(subject).to receive(:value=).with(some_value)

      subject.set_to(some_value)
    end

    it 'returns self' do
      expect(subject.set_to(1)).to be subject
    end
  end

  ([:randomize] + Array(randomize_aliases)).each do |meth|
    describe "##{meth}" do
      it 'calls #value= with #random_value' do
        allow(subject).to receive(:random_value).and_return(some_value)

        expect(subject).to receive(:value=).with(some_value)

        subject.send(meth)
      end

      it 'returns self' do
        expect(subject.send(meth)).to be subject
      end
    end
  end
end
