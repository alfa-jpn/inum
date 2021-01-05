# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inum/version'

Gem::Specification.new do |spec|
  spec.name          = 'inum'
  spec.version       = Inum::VERSION
  spec.authors       = ['alfa-jpn']
  spec.email         = ['alfa.jpn@gmail.com']
  spec.description   = 'Inum(enumerated type of Integer) provide a java-Enum-like.'
  spec.summary       = 'Inum(enumerated type of Integer) provide a java-Enum-like.'
  spec.homepage      = 'https://github.com/alfa-jpn/inum'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'coveralls'

  spec.add_dependency 'i18n'
  spec.add_dependency 'activesupport'
end
