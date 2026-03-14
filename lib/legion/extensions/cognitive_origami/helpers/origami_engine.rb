# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveOrigami
      module Helpers
        class OrigamiEngine
          def initialize
            @figures = {}
          end

          def create_figure(domain:, content:, id: nil)
            raise ArgumentError, 'domain must be a non-empty string' unless domain.is_a?(String) && !domain.empty?
            raise ArgumentError, 'content must be a non-empty string' unless content.is_a?(String) && !content.empty?
            raise ArgumentError, "Cannot exceed MAX_FIGURES (#{Constants::MAX_FIGURES})" if @figures.size >= Constants::MAX_FIGURES

            figure_id = id || SecureRandom.uuid
            figure = Figure.new(id: figure_id, domain: domain, content: content)
            @figures[figure_id] = figure
            figure
          end

          def fold_figure(id:, fold_type:, axis:)
            figure = fetch_figure!(id)
            fold_type_sym = fold_type.to_sym
            crease = figure.fold!(fold_type_sym, axis)
            Legion::Logging.debug "[cognitive_origami] fold: id=#{id[0..7]} type=#{fold_type_sym} axis=#{axis} fold_count=#{figure.fold_count}"
            { success: true, figure_id: id, crease: crease.to_h, fold_count: figure.fold_count }
          end

          def unfold_figure(id:)
            figure = fetch_figure!(id)
            result = figure.unfold!
            Legion::Logging.debug "[cognitive_origami] unfold: id=#{id[0..7]} fold_count=#{figure.fold_count} result=#{result}"
            { success: result, figure_id: id, fold_count: figure.fold_count, fully_unfolded: figure.fully_unfolded? }
          end

          def batch_fold(id:, folds:)
            figure = fetch_figure!(id)
            applied = []
            folds.each do |fold|
              fold_type_sym = fold.fetch(:fold_type).to_sym
              axis = fold.fetch(:axis)
              crease = figure.fold!(fold_type_sym, axis)
              applied << crease.to_h
            end
            Legion::Logging.debug "[cognitive_origami] batch_fold: id=#{id[0..7]} applied=#{applied.size} fold_count=#{figure.fold_count}"
            { success: true, figure_id: id, applied_count: applied.size, fold_count: figure.fold_count, creases: applied }
          end

          def most_complex(limit: 5)
            sorted = @figures.values.sort_by { |f| -f.fold_count }
            sorted.first(limit.clamp(1, @figures.size.clamp(1, Constants::MAX_FIGURES))).map(&:to_h)
          end

          def most_beautiful(limit: 5)
            sorted = @figures.values.sort_by { |f| -f.beauty_score }
            sorted.first(limit.clamp(1, @figures.size.clamp(1, Constants::MAX_FIGURES))).map(&:to_h)
          end

          def soften_all_creases!(rate: Constants::CREASE_DECAY)
            softened_count = 0
            @figures.each_value do |figure|
              figure.creases.each do |crease|
                crease.soften!(rate)
                softened_count += 1
              end
            end
            Legion::Logging.debug "[cognitive_origami] soften_all_creases: softened=#{softened_count}"
            { softened_count: softened_count }
          end

          def total_folds
            @figures.values.sum(&:fold_count)
          end

          def origami_report
            figures = @figures.values
            {
              figure_count:            figures.size,
              total_folds:             total_folds,
              average_folds:           figures.empty? ? 0.0 : (total_folds.to_f / figures.size).round(10),
              most_complex:            most_complex(limit: 3),
              most_beautiful:          most_beautiful(limit: 3),
              complexity_distribution: complexity_distribution(figures)
            }
          end

          def figures
            @figures.values.map(&:to_h)
          end

          def get_figure(id)
            @figures[id]
          end

          private

          def fetch_figure!(id)
            @figures.fetch(id) { raise ArgumentError, "Figure not found: #{id}" }
          end

          def complexity_distribution(figures)
            dist = Hash.new(0)
            figures.each { |f| dist[f.complexity] += 1 }
            dist
          end
        end
      end
    end
  end
end
