# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = 'mineradmin-client'
  spec.version       = File.read('../VERSION').strip
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
  spec.add_runtime_dependency 'mrdialog'
end
