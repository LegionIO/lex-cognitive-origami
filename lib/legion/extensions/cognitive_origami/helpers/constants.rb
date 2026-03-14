# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveOrigami
      module Helpers
        module Constants
          FOLD_TYPES = %i[valley mountain reverse squash petal].freeze
          MAX_FOLDS  = 12
          MAX_FIGURES = 100

          COMPLEXITY_LABELS = {
            (0..2)   => :simple,
            (3..5)   => :moderate,
            (6..8)   => :complex,
            (9..11)  => :intricate,
            (12..12) => :transcendent
          }.freeze

          CREASE_DECAY = 0.01
        end
      end
    end
  end
end
