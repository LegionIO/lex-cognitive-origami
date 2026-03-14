# frozen_string_literal: true

require 'securerandom'

require_relative 'cognitive_origami/version'
require_relative 'cognitive_origami/helpers/constants'
require_relative 'cognitive_origami/helpers/crease'
require_relative 'cognitive_origami/helpers/figure'
require_relative 'cognitive_origami/helpers/origami_engine'
require_relative 'cognitive_origami/runners/cognitive_origami'
require_relative 'cognitive_origami/client'

module Legion
  module Extensions
    module CognitiveOrigami
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
