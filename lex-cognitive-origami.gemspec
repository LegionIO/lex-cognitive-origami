# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_origami/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-origami'
  spec.version       = Legion::Extensions::CognitiveOrigami::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Origami'
  spec.description   = 'Concept folding engine for the LegionIO cognitive architecture — complex ideas ' \
                       'compressed through successive folds, crease patterns preserve memory of past folds, ' \
                       'unfolding reveals hidden structure'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-origami'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-cognitive-origami'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-cognitive-origami'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-cognitive-origami'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-cognitive-origami/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
