# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveOrigami::Helpers::Crease do
  let(:crease) { described_class.new(fold_type: :valley, axis: 'horizontal', depth: 1) }

  describe '#initialize' do
    it 'stores fold_type, axis, depth, and sharpness' do
      expect(crease.fold_type).to eq(:valley)
      expect(crease.axis).to eq('horizontal')
      expect(crease.depth).to eq(1)
      expect(crease.sharpness).to eq(1.0)
    end

    it 'accepts a custom sharpness' do
      c = described_class.new(fold_type: :mountain, axis: 'diagonal', depth: 2, sharpness: 0.5)
      expect(c.sharpness).to eq(0.5)
    end

    it 'clamps sharpness to 0.0..1.0' do
      high = described_class.new(fold_type: :petal, axis: 'x', depth: 1, sharpness: 2.0)
      low  = described_class.new(fold_type: :petal, axis: 'x', depth: 1, sharpness: -1.0)
      expect(high.sharpness).to eq(1.0)
      expect(low.sharpness).to eq(0.0)
    end

    it 'raises ArgumentError for unknown fold_type' do
      expect { described_class.new(fold_type: :invalid, axis: 'x', depth: 1) }
        .to raise_error(ArgumentError, /Unknown fold_type/)
    end

    it 'raises ArgumentError for empty axis' do
      expect { described_class.new(fold_type: :valley, axis: '', depth: 1) }
        .to raise_error(ArgumentError, /axis/)
    end

    it 'raises ArgumentError for non-string axis' do
      expect { described_class.new(fold_type: :valley, axis: :horizontal, depth: 1) }
        .to raise_error(ArgumentError, /axis/)
    end

    it 'raises ArgumentError for depth zero' do
      expect { described_class.new(fold_type: :valley, axis: 'x', depth: 0) }
        .to raise_error(ArgumentError, /depth/)
    end

    it 'raises ArgumentError for negative depth' do
      expect { described_class.new(fold_type: :valley, axis: 'x', depth: -1) }
        .to raise_error(ArgumentError, /depth/)
    end

    it 'accepts all valid fold_types' do
      Legion::Extensions::CognitiveOrigami::Helpers::Constants::FOLD_TYPES.each do |ft|
        c = described_class.new(fold_type: ft, axis: 'test', depth: 1)
        expect(c.fold_type).to eq(ft)
      end
    end
  end

  describe '#soften!' do
    it 'reduces sharpness by CREASE_DECAY by default' do
      rate = Legion::Extensions::CognitiveOrigami::Helpers::Constants::CREASE_DECAY
      original = crease.sharpness
      crease.soften!
      expect(crease.sharpness).to be_within(0.0001).of(original - rate)
    end

    it 'accepts a custom rate' do
      crease.soften!(0.1)
      expect(crease.sharpness).to be_within(0.0001).of(0.9)
    end

    it 'clamps sharpness to 0.0' do
      10.times { crease.soften!(0.2) }
      expect(crease.sharpness).to eq(0.0)
    end

    it 'returns self for chaining' do
      expect(crease.soften!).to eq(crease)
    end
  end

  describe '#sharp?' do
    it 'returns true when sharpness >= 0.6' do
      c = described_class.new(fold_type: :valley, axis: 'x', depth: 1, sharpness: 0.6)
      expect(c.sharp?).to be true
    end

    it 'returns false when sharpness < 0.6' do
      c = described_class.new(fold_type: :valley, axis: 'x', depth: 1, sharpness: 0.5)
      expect(c.sharp?).to be false
    end
  end

  describe '#faded?' do
    it 'returns true when sharpness <= 0.1' do
      c = described_class.new(fold_type: :valley, axis: 'x', depth: 1, sharpness: 0.1)
      expect(c.faded?).to be true
    end

    it 'returns false when sharpness > 0.1' do
      c = described_class.new(fold_type: :valley, axis: 'x', depth: 1, sharpness: 0.5)
      expect(c.faded?).to be false
    end
  end

  describe '#to_h' do
    it 'returns a hash with all fields' do
      h = crease.to_h
      expect(h[:fold_type]).to eq(:valley)
      expect(h[:axis]).to eq('horizontal')
      expect(h[:depth]).to eq(1)
      expect(h[:sharpness]).to eq(1.0)
    end

    it 'rounds sharpness to 10 decimal places' do
      crease.soften!(0.333)
      h = crease.to_h
      expect(h[:sharpness].to_s.length).to be <= 12
    end
  end
end
