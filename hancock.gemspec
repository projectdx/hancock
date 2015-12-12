# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hancock/version'

Gem::Specification.new do |spec|
  spec.name          = "hancock"
  spec.version       = Hancock::VERSION
  spec.authors       = ["projectdx"]
  spec.email         = [""]
  spec.description   = %q{Gem for submitting documents to DocuSign with electronic signature tabs.}
  spec.summary       = %q{Gem for submitting documents to DocuSign with electronic signature tabs.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency 'valid_attribute'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec-autotest'
  spec.add_development_dependency 'ZenTest'
  spec.add_development_dependency 'autotest-growl'

  spec.add_dependency "nokogiri"
  spec.add_dependency 'activesupport'
  spec.add_dependency 'faraday'            # http library
  spec.add_dependency 'faraday_middleware' # allows redirects
  spec.add_dependency 'typhoeus'           # runs http requests in parallel
  spec.add_dependency 'activemodel'
end
