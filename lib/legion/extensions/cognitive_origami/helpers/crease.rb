# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveOrigami
      module Helpers
        class Crease
          SHARP_THRESHOLD = 0.6
          FADED_THRESHOLD = 0.1

          attr_reader :fold_type, :axis, :depth, :sharpness

          def initialize(fold_type:, axis:, depth:, sharpness: 1.0)
            raise ArgumentError, "Unknown fold_type: #{fold_type}" unless Constants::FOLD_TYPES.include?(fold_type)
            raise ArgumentError, 'axis must be a non-empty string' unless axis.is_a?(String) && !axis.empty?
            raise ArgumentError, 'depth must be a positive integer' unless depth.is_a?(Integer) && depth >= 1

            @fold_type = fold_type
            @axis      = axis
            @depth     = depth
            @sharpness = sharpness.clamp(0.0, 1.0)
          end

          def soften!(rate = Constants::CREASE_DECAY)
            @sharpness = (@sharpness - rate).clamp(0.0, 1.0)
            self
          end

          def sharp?
            @sharpness >= SHARP_THRESHOLD
          end

          def faded?
            @sharpness <= FADED_THRESHOLD
          end

          def to_h
            {
              fold_type: @fold_type,
              axis:      @axis,
              depth:     @depth,
              sharpness: @sharpness.round(10)
            }
          end
        end
      end
    end
  end
end
