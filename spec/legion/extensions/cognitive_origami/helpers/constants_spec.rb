# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveOrigami::Helpers::Constants do
  describe 'FOLD_TYPES' do
    it 'contains the five fold types' do
      expect(described_class::FOLD_TYPES).to eq(%i[valley mountain reverse squash petal])
    end

    it 'is frozen' do
      expect(described_class::FOLD_TYPES).to be_frozen
    end
  end

  describe 'MAX_FOLDS' do
    it 'is 12' do
      expect(described_class::MAX_FOLDS).to eq(12)
    end
  end

  describe 'MAX_FIGURES' do
    it 'is 100' do
      expect(described_class::MAX_FIGURES).to eq(100)
    end
  end

  describe 'COMPLEXITY_LABELS' do
    it 'returns :simple for fold counts 0..2' do
      (0..2).each do |n|
        label = described_class::COMPLEXITY_LABELS.find { |range, _| range.include?(n) }
        expect(label[1]).to eq(:simple)
      end
    end

    it 'returns :moderate for fold counts 3..5' do
      (3..5).each do |n|
        label = described_class::COMPLEXITY_LABELS.find { |range, _| range.include?(n) }
        expect(label[1]).to eq(:moderate)
      end
    end

    it 'returns :complex for fold counts 6..8' do
      (6..8).each do |n|
        label = described_class::COMPLEXITY_LABELS.find { |range, _| range.include?(n) }
        expect(label[1]).to eq(:complex)
      end
    end

    it 'returns :intricate for fold counts 9..11' do
      (9..11).each do |n|
        label = described_class::COMPLEXITY_LABELS.find { |range, _| range.include?(n) }
        expect(label[1]).to eq(:intricate)
      end
    end

    it 'returns :transcendent for fold count 12' do
      label = described_class::COMPLEXITY_LABELS.find { |range, _| range.include?(12) }
      expect(label[1]).to eq(:transcendent)
    end

    it 'is frozen' do
      expect(described_class::COMPLEXITY_LABELS).to be_frozen
    end
  end

  describe 'CREASE_DECAY' do
    it 'is 0.01' do
      expect(described_class::CREASE_DECAY).to eq(0.01)
    end
  end
end
