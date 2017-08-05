# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = 'minerd'
  spec.version       = File.read('../VERSION').strip
  spec.authors       = ['Jakub Skokan']
  spec.email         = ['jakub.skokan@vpsfree.cz']
  spec.summary       =
  spec.description   = 'Process manager used by MinerAdmin'
  spec.homepage      = ''
  spec.license       = 'GPL'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'

  spec.add_runtime_dependency 'json'
end
