# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveOrigami::Helpers::OrigamiEngine do
  let(:engine) { described_class.new }

  def create_fig(domain: 'science', content: 'quantum entanglement', id: nil)
    engine.create_figure(domain: domain, content: content, id: id)
  end

  describe '#create_figure' do
    it 'creates and returns a Figure' do
      figure = create_fig
      expect(figure).to be_a(Legion::Extensions::CognitiveOrigami::Helpers::Figure)
    end

    it 'assigns a UUID id when none provided' do
      figure = create_fig
      expect(figure.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'uses provided id' do
      figure = create_fig(id: 'my-custom-id')
      expect(figure.id).to eq('my-custom-id')
    end

    it 'stores the figure in the engine' do
      figure = create_fig
      expect(engine.get_figure(figure.id)).to eq(figure)
    end

    it 'raises ArgumentError for empty domain' do
      expect { engine.create_figure(domain: '', content: 'test') }
        .to raise_error(ArgumentError, /domain/)
    end

    it 'raises ArgumentError for empty content' do
      expect { engine.create_figure(domain: 'test', content: '') }
        .to raise_error(ArgumentError, /content/)
    end

    it 'raises ArgumentError when MAX_FIGURES is reached' do
      max = Legion::Extensions::CognitiveOrigami::Helpers::Constants::MAX_FIGURES
      max.times { |i| engine.create_figure(domain: 'd', content: "c#{i}") }
      expect { engine.create_figure(domain: 'd', content: 'overflow') }
        .to raise_error(ArgumentError, /MAX_FIGURES/)
    end
  end

  describe '#fold_figure' do
    let(:figure) { create_fig }

    it 'folds the figure and returns a result hash' do
      result = engine.fold_figure(id: figure.id, fold_type: :valley, axis: 'horizontal')
      expect(result[:success]).to be true
      expect(result[:fold_count]).to eq(1)
    end

    it 'includes crease details in result' do
      result = engine.fold_figure(id: figure.id, fold_type: :mountain, axis: 'vertical')
      expect(result[:crease]).to include(fold_type: :mountain, axis: 'vertical')
    end

    it 'raises ArgumentError for unknown figure' do
      expect { engine.fold_figure(id: 'nope', fold_type: :valley, axis: 'x') }
        .to raise_error(ArgumentError, /Figure not found/)
    end

    it 'accepts string fold_type and converts to symbol' do
      result = engine.fold_figure(id: figure.id, fold_type: 'squash', axis: 'x')
      expect(result[:crease][:fold_type]).to eq(:squash)
    end
  end

  describe '#unfold_figure' do
    let(:figure) { create_fig }

    it 'unfolds the figure' do
      engine.fold_figure(id: figure.id, fold_type: :valley, axis: 'x')
      result = engine.unfold_figure(id: figure.id)
      expect(result[:success]).to be true
      expect(result[:fold_count]).to eq(0)
    end

    it 'returns fully_unfolded: true when at zero folds' do
      engine.fold_figure(id: figure.id, fold_type: :valley, axis: 'x')
      result = engine.unfold_figure(id: figure.id)
      expect(result[:fully_unfolded]).to be true
    end

    it 'returns success: false when already fully unfolded' do
      result = engine.unfold_figure(id: figure.id)
      expect(result[:success]).to be false
    end

    it 'raises ArgumentError for unknown figure' do
      expect { engine.unfold_figure(id: 'missing') }
        .to raise_error(ArgumentError, /Figure not found/)
    end
  end

  describe '#batch_fold' do
    let(:figure) { create_fig }
    let(:folds) do
      [
        { fold_type: :valley, axis: 'h' },
        { fold_type: :mountain, axis: 'v' },
        { fold_type: :reverse, axis: 'd' }
      ]
    end

    it 'applies all folds and returns count' do
      result = engine.batch_fold(id: figure.id, folds: folds)
      expect(result[:success]).to be true
      expect(result[:applied_count]).to eq(3)
      expect(result[:fold_count]).to eq(3)
    end

    it 'includes all applied creases in result' do
      result = engine.batch_fold(id: figure.id, folds: folds)
      expect(result[:creases].size).to eq(3)
    end

    it 'raises ArgumentError for unknown figure' do
      expect { engine.batch_fold(id: 'nope', folds: folds) }
        .to raise_error(ArgumentError, /Figure not found/)
    end
  end

  describe '#most_complex' do
    it 'returns figures sorted by fold_count descending' do
      f1 = create_fig(content: 'one')
      f2 = create_fig(content: 'two')
      engine.fold_figure(id: f1.id, fold_type: :valley, axis: 'x')
      3.times { engine.fold_figure(id: f2.id, fold_type: :mountain, axis: 'y') }
      result = engine.most_complex(limit: 2)
      expect(result.first[:fold_count]).to be >= result.last[:fold_count]
    end

    it 'respects the limit' do
      5.times { create_fig(content: "c#{SecureRandom.uuid}") }
      expect(engine.most_complex(limit: 3).size).to be <= 3
    end
  end

  describe '#most_beautiful' do
    it 'returns figures sorted by beauty_score descending' do
      create_fig(content: 'plain')
      f2 = create_fig(content: 'ornate')
      5.times { engine.fold_figure(id: f2.id, fold_type: :petal, axis: 'p') }
      result = engine.most_beautiful(limit: 2)
      expect(result.first[:beauty_score]).to be >= result.last[:beauty_score]
    end
  end

  describe '#soften_all_creases!' do
    it 'returns softened_count' do
      fig = create_fig
      engine.fold_figure(id: fig.id, fold_type: :valley, axis: 'x')
      engine.fold_figure(id: fig.id, fold_type: :mountain, axis: 'y')
      result = engine.soften_all_creases!
      expect(result[:softened_count]).to eq(2)
    end

    it 'reduces sharpness on all creases' do
      fig = create_fig
      engine.fold_figure(id: fig.id, fold_type: :valley, axis: 'x')
      engine.soften_all_creases!
      crease = engine.get_figure(fig.id).creases.first
      expect(crease.sharpness).to be < 1.0
    end

    it 'accepts custom rate' do
      fig = create_fig
      engine.fold_figure(id: fig.id, fold_type: :valley, axis: 'x')
      engine.soften_all_creases!(rate: 0.5)
      crease = engine.get_figure(fig.id).creases.first
      expect(crease.sharpness).to be_within(0.001).of(0.5)
    end
  end

  describe '#total_folds' do
    it 'sums fold_count across all figures' do
      f1 = create_fig(content: 'a')
      f2 = create_fig(content: 'b')
      engine.fold_figure(id: f1.id, fold_type: :valley, axis: 'x')
      engine.fold_figure(id: f1.id, fold_type: :mountain, axis: 'y')
      engine.fold_figure(id: f2.id, fold_type: :squash, axis: 'z')
      expect(engine.total_folds).to eq(3)
    end

    it 'returns 0 with no figures' do
      expect(engine.total_folds).to eq(0)
    end
  end

  describe '#origami_report' do
    it 'returns a comprehensive report hash' do
      f = create_fig
      engine.fold_figure(id: f.id, fold_type: :valley, axis: 'x')
      report = engine.origami_report
      expect(report).to include(:figure_count, :total_folds, :average_folds, :most_complex, :most_beautiful, :complexity_distribution)
    end

    it 'reports zero averages when no figures' do
      expect(engine.origami_report[:average_folds]).to eq(0.0)
    end

    it 'includes complexity_distribution' do
      f = create_fig
      engine.fold_figure(id: f.id, fold_type: :valley, axis: 'x')
      dist = engine.origami_report[:complexity_distribution]
      expect(dist).to include(:simple).or include(:moderate)
    end
  end

  describe '#figures' do
    it 'returns all figures as hashes' do
      create_fig(content: 'alpha')
      create_fig(content: 'beta')
      expect(engine.figures.size).to eq(2)
      expect(engine.figures.first).to be_a(Hash)
    end

    it 'returns empty array when no figures' do
      expect(engine.figures).to eq([])
    end
  end

  describe '#get_figure' do
    it 'returns the figure by id' do
      fig = create_fig
      expect(engine.get_figure(fig.id)).to eq(fig)
    end

    it 'returns nil for unknown id' do
      expect(engine.get_figure('nonexistent')).to be_nil
    end
  end
end
