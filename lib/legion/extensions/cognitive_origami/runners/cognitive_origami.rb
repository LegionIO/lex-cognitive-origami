# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveOrigami
      module Runners
        module CognitiveOrigami
          extend self

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create(domain:, content:, id: nil, engine: nil, **)
            eng = engine || default_engine
            figure = eng.create_figure(id: id, domain: domain, content: content)
            Legion::Logging.debug "[cognitive_origami] create: id=#{figure.id[0..7]} domain=#{domain}"
            { success: true, figure: figure.to_h }
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_origami] create failed: #{e.message}"
            { success: false, error: e.message }
          end

          def fold(id:, fold_type:, axis:, engine: nil, **)
            eng = engine || default_engine
            eng.fold_figure(id: id, fold_type: fold_type, axis: axis)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_origami] fold failed: #{e.message}"
            { success: false, error: e.message }
          end

          def unfold(id:, engine: nil, **)
            eng = engine || default_engine
            eng.unfold_figure(id: id)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_origami] unfold failed: #{e.message}"
            { success: false, error: e.message }
          end

          def list_figures(engine: nil, **)
            eng = engine || default_engine
            figures = eng.figures
            Legion::Logging.debug "[cognitive_origami] list_figures: count=#{figures.size}"
            { success: true, figures: figures, count: figures.size }
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_origami] list_figures failed: #{e.message}"
            { success: false, error: e.message }
          end

          def origami_status(engine: nil, **)
            eng = engine || default_engine
            report = eng.origami_report
            Legion::Logging.debug "[cognitive_origami] status: figures=#{report[:figure_count]} total_folds=#{report[:total_folds]}"
            { success: true, report: report }
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_origami] origami_status failed: #{e.message}"
            { success: false, error: e.message }
          end

          private

          def default_engine
            @default_engine ||= Helpers::OrigamiEngine.new
          end
        end
      end
    end
  end
end
