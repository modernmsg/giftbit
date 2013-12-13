# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kiind/version'

Gem::Specification.new do |spec|
  spec.name          = "kiind"
  spec.version       = Kiind::VERSION
  spec.authors       = ["Audee Velasco"]
  spec.email         = ["auds@adooylabs.com"]
  spec.description   = %q{this gem integrates kiind.me platform to your ruby apps}
  spec.summary       = %q{a gem for kiind.me platform}
  spec.homepage      = "http://www.adooylabs.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency('rest-client')
  spec.add_dependency('multi_json')
  
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
