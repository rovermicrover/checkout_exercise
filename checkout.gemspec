# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkout_support/version'

Gem::Specification.new do |spec|
  spec.name          = "checkout"
  spec.date          = '2017-05-22'
  spec.version       = CheckoutSupport::VERSION
  spec.authors       = ["Andrew Rove"]
  spec.email         = ["andrew.m.rove@gmail.com"]
  spec.summary       = %q{Checkout}
  spec.description   = %q{For exercise https://gist.github.com/joshkeys/24733109a23ef3b90463cc1c46f3238a}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 11"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "mocha"
end
