# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name    = 'dm-accepts_nested_attributes'
  s.version = '1.1.0'
  s.license = 'MIT'

  s.authors     = ['Martin Gamsjaeger (snusnu)']
  s.email       = 'gamsnjaga [a] gmail [d] com'
  s.summary     = %{Nested model assignment for datamapper}
  s.description = %{A datamapper plugin that allows nested model assignment like activerecord.}
  s.homepage = %q{http://github.com/snusnu/dm-accepts_nested_attributes}

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec}/*`.split("\n")
  s.extra_rdoc_files = %w[LICENSE.txt README.md]
  s.require_paths    = ['lib']

  s.add_dependency 'dm-core', ['>= 1.1.0.rc0', '< 1.2']
  s.add_development_dependency 'dm-validations', ['>= 1.1.0.rc0', '< 1.2']
  s.add_development_dependency 'dm-constraints', ['>= 1.1.0.rc0', '< 1.2']
  s.add_development_dependency 'rake', '~> 0.8.7'
  s.add_development_dependency 'rspec', '~> 1.3'
  s.add_development_dependency 'yard', '~> 0.5'
  s.add_development_dependency 'rcov', '~> 0.9.7'
end
