# -*- encoding: utf-8 -*-
require File.expand_path('../lib/data_mapper/nested_attributes/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors     = [ 'Martin Gamsjaeger (snusnu)' ]
  gem.email       = [ 'gamsnjaga@gmail.com' ]
  gem.summary     = "A DataMapper plugin that allows nested model assignment like ActiveRecord."
  gem.description = gem.summary
  gem.homepage    = "http://github.com/snusnu/dm-accepts_nested_attributes"

  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec,test}/*`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE README.textile]

  gem.name          = "dm-accepts_nested_attributes"
  gem.require_paths = [ "lib" ]
  gem.version       = DataMapper::NestedAttributes::VERSION

  gem.add_runtime_dependency('dm-core', '~> 1.3.0.beta')

  gem.add_development_dependency('dm-validations', '~> 1.3.0.beta')
  gem.add_development_dependency('dm-constraints', '~> 1.3.0.beta')
  gem.add_development_dependency('rake',           '~> 0.9.2')
  gem.add_development_dependency('rspec',          '~> 1.3.2')
end
