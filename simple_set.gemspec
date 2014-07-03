# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_set/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_set"
  spec.version       = SimpleSet::VERSION
  spec.authors       = ["Romain Tartière"]
  spec.email         = ["romain@blogreen.org"]
  spec.summary       = %q{Simple set-like field support for ActiveModel}
  spec.homepage      = "https://github.com/sante-link/simple_set"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'activerecord', '>= 3.0.0'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
end
