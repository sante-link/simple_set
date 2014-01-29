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
  spec.homepage      = "https://github.com/smortex/simple_set"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "simple_enum", "~> 1.6.8"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activerecord", ">= 3.0.0"
end
