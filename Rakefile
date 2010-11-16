require 'rubygems'
require 'rake'

begin

  require 'jeweler'

  Jeweler::Tasks.new do |gem|

    gem.name        = 'dm-accepts_nested_attributes'
    gem.summary     = 'Nested model assignment for datamapper'
    gem.description = 'A datamapper plugin that allows nested model assignment like activerecord.'
    gem.email       = 'gamsnjaga [a] gmail [d] com'
    gem.homepage    = 'http://github.com/snusnu/dm-accepts_nested_attributes'
    gem.authors     = [ 'Martin Gamsjaeger (snusnu)' ]

    gem.add_dependency             'dm-core', '~> 1.0.0'

    gem.add_development_dependency 'rspec',   '~> 1.3'
    gem.add_development_dependency 'yard',    '~> 0.5'

  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }

rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
