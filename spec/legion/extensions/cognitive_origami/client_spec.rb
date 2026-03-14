# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveOrigami::Client do
  let(:client) { described_class.new }

  describe '#initialize' do
    it 'creates an OrigamiEngine by default' do
      expect(client.engine).to be_a(Legion::Extensions::CognitiveOrigami::Helpers::OrigamiEngine)
    end

    it 'accepts an injected engine' do
      custom_engine = Legion::Extensions::CognitiveOrigami::Helpers::OrigamiEngine.new
      c = described_class.new(engine: custom_engine)
      expect(c.engine).to eq(custom_engine)
    end
  end

  describe '#create' do
    it 'creates a figure through the client engine' do
      result = client.create(domain: 'biology', content: 'cell division')
      expect(result[:success]).to be true
      expect(result[:figure][:domain]).to eq('biology')
    end

    it 'returns an error for invalid input' do
      result = client.create(domain: '', content: 'test')
      expect(result[:success]).to be false
    end
  end

  describe '#fold' do
    let(:figure_id) do
      result = client.create(domain: 'physics', content: 'spacetime curvature')
      result[:figure][:id]
    end

    it 'folds the figure' do
      result = client.fold(id: figure_id, fold_type: :valley, axis: 'temporal')
      expect(result[:success]).to be true
      expect(result[:fold_count]).to eq(1)
    end

    it 'returns error for unknown figure' do
      result = client.fold(id: 'unknown', fold_type: :valley, axis: 'x')
      expect(result[:success]).to be false
    end
  end

  describe '#unfold' do
    let(:figure_id) do
      result = client.create(domain: 'chemistry', content: 'molecular bonding')
      id = result[:figure][:id]
      client.fold(id: id, fold_type: :mountain, axis: 'spatial')
      id
    end

    it 'unfolds the figure' do
      result = client.unfold(id: figure_id)
      expect(result[:success]).to be true
      expect(result[:fully_unfolded]).to be true
    end
  end

  describe '#list_figures' do
    it 'lists all figures in the client engine' do
      client.create(domain: 'art', content: 'color theory')
      client.create(domain: 'music', content: 'harmony')
      result = client.list_figures
      expect(result[:success]).to be true
      expect(result[:count]).to eq(2)
    end
  end

  describe '#origami_status' do
    it 'returns status report' do
      client.create(domain: 'philosophy', content: 'epistemology')
      result = client.origami_status
      expect(result[:success]).to be true
      expect(result[:report][:figure_count]).to eq(1)
    end
  end

  describe 'full lifecycle' do
    it 'creates, folds, status, unfolds, and verifies' do
      create_result = client.create(domain: 'cognition', content: 'working memory')
      id = create_result[:figure][:id]

      3.times { |i| client.fold(id: id, fold_type: :valley, axis: "axis#{i}") }
      status = client.origami_status
      expect(status[:report][:total_folds]).to eq(3)

      client.unfold(id: id)
      figures = client.list_figures
      target = figures[:figures].find { |f| f[:id] == id }
      expect(target[:fold_count]).to eq(2)
    end
  end
end
