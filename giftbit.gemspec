lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'giftbit/version'

Gem::Specification.new do |spec|
  spec.name          = 'giftbit'
  spec.version       = Giftbit::VERSION
  spec.authors       = ['Sean Linsley']
  spec.email         = ['sean@modernmsg.com']
  spec.summary       = 'A Ruby gem for the Giftbit API'
  spec.homepage      = 'https://www.github.com/modernmsg/giftbit'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(/spec\//)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2'

  spec.add_dependency 'rest-client'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
end
