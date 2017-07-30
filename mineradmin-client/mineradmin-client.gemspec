# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mineradmin/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'mineradmin-client'
  spec.version       = MinerAdmin::Client::VERSION
  spec.authors       = ['Jakub Skokan']
  spec.email         = ['jakub.skokan@vpsfree.cz']
  spec.summary       =
  spec.description   = 'Ruby API and CLI for minerAdmin API'
  spec.homepage      = ''
  spec.license       = 'GPL'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'

  spec.add_runtime_dependency 'haveapi-client', '~> 0.9.0'
  spec.add_runtime_dependency 'eventmachine'
  spec.add_runtime_dependency 'websocket-eventmachine-client'
end
