# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveOrigami
      class Client
        include Runners::CognitiveOrigami

        attr_reader :engine

        def initialize(engine: nil, **)
          @engine = engine || Helpers::OrigamiEngine.new
        end

        def create(domain:, content:, id: nil, **)
          super(domain: domain, content: content, id: id, engine: @engine)
        end

        def fold(id:, fold_type:, axis:, **)
          super(id: id, fold_type: fold_type, axis: axis, engine: @engine)
        end

        def unfold(id:, **)
          super(id: id, engine: @engine)
        end

        def list_figures(**)
          super(engine: @engine)
        end

        def origami_status(**)
          super(engine: @engine)
        end
      end
    end
  end
end
