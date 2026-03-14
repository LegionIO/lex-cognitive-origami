# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveOrigami::Runners::CognitiveOrigami do
  let(:engine) { Legion::Extensions::CognitiveOrigami::Helpers::OrigamiEngine.new }
  let(:runner) { Object.new.extend(described_module) }
  let(:described_module) { described_class }

  # Helper to create a figure in the engine
  def make_figure(engine, domain: 'logic', content: 'syllogism')
    engine.create_figure(domain: domain, content: content)
  end

  describe '.create' do
    it 'creates a figure and returns success: true' do
      result = described_class.create(domain: 'ethics', content: 'virtue', engine: engine)
      expect(result[:success]).to be true
      expect(result[:figure]).to include(:id, :domain, :content)
    end

    it 'returns a figure with matching domain and content' do
      result = described_class.create(domain: 'ethics', content: 'deontology', engine: engine)
      expect(result[:figure][:domain]).to eq('ethics')
      expect(result[:figure][:content]).to eq('deontology')
    end

    it 'accepts an explicit id' do
      result = described_class.create(domain: 'logic', content: 'modus ponens', id: 'custom-001', engine: engine)
      expect(result[:figure][:id]).to eq('custom-001')
    end

    it 'returns success: false on ArgumentError' do
      result = described_class.create(domain: '', content: 'test', engine: engine)
      expect(result[:success]).to be false
      expect(result[:error]).to include('domain')
    end
  end

  describe '.fold' do
    let(:figure) { make_figure(engine) }

    it 'folds a figure and returns success: true' do
      result = described_class.fold(id: figure.id, fold_type: :valley, axis: 'x', engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns fold_count after folding' do
      result = described_class.fold(id: figure.id, fold_type: :mountain, axis: 'y', engine: engine)
      expect(result[:fold_count]).to eq(1)
    end

    it 'returns success: false for unknown figure' do
      result = described_class.fold(id: 'nope', fold_type: :valley, axis: 'x', engine: engine)
      expect(result[:success]).to be false
    end

    it 'returns success: false for invalid fold_type' do
      result = described_class.fold(id: figure.id, fold_type: :bogus, axis: 'x', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '.unfold' do
    let(:figure) { make_figure(engine) }

    before { engine.fold_figure(id: figure.id, fold_type: :valley, axis: 'x') }

    it 'unfolds a figure and returns result hash' do
      result = described_class.unfold(id: figure.id, engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns success: false for unknown figure' do
      result = described_class.unfold(id: 'ghost', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '.list_figures' do
    it 'returns success: true with figures array' do
      engine.create_figure(domain: 'art', content: 'perspective')
      result = described_class.list_figures(engine: engine)
      expect(result[:success]).to be true
      expect(result[:figures]).to be_an(Array)
      expect(result[:count]).to eq(1)
    end

    it 'returns empty figures when engine has none' do
      result = described_class.list_figures(engine: engine)
      expect(result[:count]).to eq(0)
      expect(result[:figures]).to be_empty
    end
  end

  describe '.origami_status' do
    it 'returns success: true with a report' do
      result = described_class.origami_status(engine: engine)
      expect(result[:success]).to be true
      expect(result[:report]).to include(:figure_count, :total_folds)
    end

    it 'reports zero figures on empty engine' do
      result = described_class.origami_status(engine: engine)
      expect(result[:report][:figure_count]).to eq(0)
    end

    it 'reflects created figures in the report' do
      engine.create_figure(domain: 'math', content: 'topology')
      result = described_class.origami_status(engine: engine)
      expect(result[:report][:figure_count]).to eq(1)
    end
  end
end
