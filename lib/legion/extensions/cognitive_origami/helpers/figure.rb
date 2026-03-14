# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveOrigami
      module Helpers
        class Figure
          BASE_SIZE            = 1.0
          COMPRESSION_PER_FOLD = 0.07
          BEAUTY_FOLD_BONUS    = 0.06
          BEAUTY_CREASE_BONUS  = 0.04
          BEAUTY_BASE          = 0.1

          attr_reader :id, :domain, :content, :creases, :fold_count, :beauty_score

          def initialize(id:, domain:, content:)
            @id           = id
            @domain       = domain
            @content      = content
            @creases      = []
            @fold_count   = 0
            @beauty_score = 0.0
            @unfolded     = false
          end

          def fold!(fold_type, axis)
            raise ArgumentError, "Unknown fold_type: #{fold_type}" unless Constants::FOLD_TYPES.include?(fold_type)
            raise ArgumentError, 'axis must be a non-empty string' unless axis.is_a?(String) && !axis.empty?
            raise ArgumentError, "Cannot exceed MAX_FOLDS (#{Constants::MAX_FOLDS})" if @fold_count >= Constants::MAX_FOLDS

            @fold_count += 1
            @unfolded    = false
            crease = Crease.new(fold_type: fold_type, axis: axis, depth: @fold_count)
            @creases << crease
            @beauty_score = compute_beauty
            crease
          end

          def unfold!
            return false if @fold_count.zero?

            @fold_count  -= 1
            @unfolded     = true
            @beauty_score = compute_beauty
            true
          end

          def fully_unfolded?
            @fold_count.zero?
          end

          def complexity
            label = Constants::COMPLEXITY_LABELS.find { |range, _| range.include?(@fold_count) }
            label ? label[1] : :simple
          end

          def compressed_size
            reduction = @fold_count * COMPRESSION_PER_FOLD
            (BASE_SIZE - reduction).clamp(0.0, BASE_SIZE).round(10)
          end

          def compression_ratio
            return 1.0 if @fold_count.zero?

            (BASE_SIZE / compressed_size.clamp(0.001, BASE_SIZE)).round(10)
          end

          def crease_pattern
            @creases.map(&:to_h)
          end

          def to_h
            {
              id:                @id,
              domain:            @domain,
              content:           @content,
              fold_count:        @fold_count,
              compressed_size:   compressed_size,
              beauty_score:      @beauty_score.round(10),
              compression_ratio: compression_ratio,
              complexity:        complexity,
              crease_count:      @creases.size,
              unfolded:          @unfolded
            }
          end

          private

          def compute_beauty
            fold_contribution   = [@fold_count * BEAUTY_FOLD_BONUS, 0.5].min
            crease_contribution = [active_creases * BEAUTY_CREASE_BONUS, 0.4].min
            (BEAUTY_BASE + fold_contribution + crease_contribution).clamp(0.0, 1.0).round(10)
          end

          def active_creases
            @creases.count { |c| !c.faded? }
          end
        end
      end
    end
  end
end
