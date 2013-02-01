# -*- encoding: utf-8 -*-

require File.expand_path('../lib/data_mapper/nested_attributes/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'dm-accepts_nested_attributes'
  s.version = DataMapper::NestedAttributes::VERSION
  s.license = 'MIT'

  s.authors     = ['Martin Gamsjaeger (snusnu)']
  s.email       = 'gamsnjaga [a] gmail [d] com'
  s.summary     = %{Nested model assignment for datamapper}
  s.description = %{A datamapper plugin that allows nested model assignment like activerecord.}
  s.homepage    = 'http://github.com/snusnu/dm-accepts_nested_attributes'

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec}/*`.split("\n")
  s.extra_rdoc_files = %w[LICENSE.txt README.md]
  s.require_paths    = ['lib']

  s.add_dependency 'dm-core', '~> 1.2'
  s.add_development_dependency 'dm-validations', '~> 1.2'
  s.add_development_dependency 'dm-constraints', '~> 1.2'
  s.add_development_dependency 'rake', '~> 0.9'
  s.add_development_dependency 'rspec', '~> 1.3'
  s.add_development_dependency 'yard', '~> 0.8'
  s.add_development_dependency 'rcov', '~> 0.9'
end
