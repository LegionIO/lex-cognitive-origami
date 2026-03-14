# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveOrigami::Helpers::Figure do
  let(:figure) { described_class.new(id: 'test-id', domain: 'philosophy', content: 'consciousness') }

  describe '#initialize' do
    it 'stores id, domain, and content' do
      expect(figure.id).to eq('test-id')
      expect(figure.domain).to eq('philosophy')
      expect(figure.content).to eq('consciousness')
    end

    it 'starts with zero folds' do
      expect(figure.fold_count).to eq(0)
    end

    it 'starts with an empty creases array' do
      expect(figure.creases).to be_empty
    end

    it 'starts with zero beauty_score' do
      expect(figure.beauty_score).to eq(0.0)
    end
  end

  describe '#fold!' do
    it 'increments fold_count' do
      figure.fold!(:valley, 'horizontal')
      expect(figure.fold_count).to eq(1)
    end

    it 'returns a Crease' do
      crease = figure.fold!(:mountain, 'vertical')
      expect(crease).to be_a(Legion::Extensions::CognitiveOrigami::Helpers::Crease)
    end

    it 'adds crease to creases array' do
      figure.fold!(:valley, 'diagonal')
      expect(figure.creases.size).to eq(1)
    end

    it 'records the fold depth correctly' do
      figure.fold!(:valley, 'h1')
      figure.fold!(:mountain, 'h2')
      expect(figure.creases[0].depth).to eq(1)
      expect(figure.creases[1].depth).to eq(2)
    end

    it 'updates beauty_score after folding' do
      figure.fold!(:valley, 'x')
      expect(figure.beauty_score).to be > 0.0
    end

    it 'raises ArgumentError for unknown fold_type' do
      expect { figure.fold!(:invalid, 'x') }.to raise_error(ArgumentError, /Unknown fold_type/)
    end

    it 'raises ArgumentError for empty axis' do
      expect { figure.fold!(:valley, '') }.to raise_error(ArgumentError, /axis/)
    end

    it 'raises ArgumentError when exceeding MAX_FOLDS' do
      max = Legion::Extensions::CognitiveOrigami::Helpers::Constants::MAX_FOLDS
      max.times { |i| figure.fold!(:valley, "axis#{i}") }
      expect { figure.fold!(:valley, 'one_too_many') }.to raise_error(ArgumentError, /MAX_FOLDS/)
    end

    it 'accepts all valid fold types' do
      Legion::Extensions::CognitiveOrigami::Helpers::Constants::FOLD_TYPES.each_with_index do |ft, i|
        figure.fold!(ft, "axis#{i}")
      end
      expect(figure.fold_count).to eq(5)
    end
  end

  describe '#unfold!' do
    it 'decrements fold_count' do
      figure.fold!(:valley, 'h')
      figure.unfold!
      expect(figure.fold_count).to eq(0)
    end

    it 'returns true when successfully unfolded' do
      figure.fold!(:valley, 'h')
      expect(figure.unfold!).to be true
    end

    it 'returns false when already fully unfolded' do
      expect(figure.unfold!).to be false
    end

    it 'does not remove creases (crease pattern preserved)' do
      figure.fold!(:mountain, 'x')
      figure.unfold!
      expect(figure.creases.size).to eq(1)
    end

    it 'updates beauty_score after unfolding' do
      figure.fold!(:valley, 'x')
      before_beauty = figure.beauty_score
      figure.unfold!
      expect(figure.beauty_score).to be < before_beauty
    end
  end

  describe '#fully_unfolded?' do
    it 'is true when fold_count is zero' do
      expect(figure.fully_unfolded?).to be true
    end

    it 'is false when there are folds' do
      figure.fold!(:valley, 'x')
      expect(figure.fully_unfolded?).to be false
    end

    it 'is true again after unfolding all folds' do
      figure.fold!(:valley, 'x')
      figure.unfold!
      expect(figure.fully_unfolded?).to be true
    end
  end

  describe '#complexity' do
    it 'returns :simple for 0 folds' do
      expect(figure.complexity).to eq(:simple)
    end

    it 'returns :moderate for 4 folds' do
      4.times { |i| figure.fold!(:valley, "a#{i}") }
      expect(figure.complexity).to eq(:moderate)
    end

    it 'returns :complex for 7 folds' do
      7.times { |i| figure.fold!(:valley, "a#{i}") }
      expect(figure.complexity).to eq(:complex)
    end

    it 'returns :intricate for 10 folds' do
      10.times { |i| figure.fold!(:valley, "a#{i}") }
      expect(figure.complexity).to eq(:intricate)
    end

    it 'returns :transcendent for 12 folds' do
      12.times { |i| figure.fold!(:valley, "a#{i}") }
      expect(figure.complexity).to eq(:transcendent)
    end
  end

  describe '#compressed_size' do
    it 'is 1.0 when unfolded' do
      expect(figure.compressed_size).to eq(1.0)
    end

    it 'decreases with each fold' do
      prev = figure.compressed_size
      figure.fold!(:valley, 'x')
      expect(figure.compressed_size).to be < prev
    end

    it 'is always >= 0.0' do
      12.times { |i| figure.fold!(:mountain, "a#{i}") }
      expect(figure.compressed_size).to be >= 0.0
    end
  end

  describe '#compression_ratio' do
    it 'is 1.0 when unfolded' do
      expect(figure.compression_ratio).to eq(1.0)
    end

    it 'increases with each fold' do
      figure.fold!(:valley, 'x')
      expect(figure.compression_ratio).to be > 1.0
    end
  end

  describe '#crease_pattern' do
    it 'returns an empty array when no folds' do
      expect(figure.crease_pattern).to be_empty
    end

    it 'returns array of crease hashes' do
      figure.fold!(:valley, 'horizontal')
      figure.fold!(:mountain, 'vertical')
      pattern = figure.crease_pattern
      expect(pattern.size).to eq(2)
      expect(pattern.first[:fold_type]).to eq(:valley)
      expect(pattern.last[:fold_type]).to eq(:mountain)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = figure.to_h
      expect(h).to include(
        :id, :domain, :content, :fold_count, :compressed_size,
        :beauty_score, :compression_ratio, :complexity, :crease_count, :unfolded
      )
    end

    it 'reflects current fold_count' do
      figure.fold!(:valley, 'x')
      expect(figure.to_h[:fold_count]).to eq(1)
    end

    it 'reflects crease_count matching creases array size' do
      figure.fold!(:valley, 'x')
      figure.fold!(:squash, 'y')
      expect(figure.to_h[:crease_count]).to eq(2)
    end
  end
end
