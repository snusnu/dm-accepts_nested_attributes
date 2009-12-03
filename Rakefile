require 'rubygems'
require 'rake'

require File.expand_path('../lib/dm-accepts_nested_attributes/version', __FILE__)

FileList['tasks/**/*.rake'].each { |task| load task }

begin

  gem 'jeweler', '~> 1.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|

    gem.version     = DataMapper::NestedAttributes::VERSION

    gem.name        = 'dm-accepts_nested_attributes'
    gem.summary     = 'Nested model assignment for datamapper'
    gem.description = 'A datamapper plugin that allows nested model assignment like activerecord.'
    gem.email       = 'gamsnjaga [a] gmail [d] com'
    gem.homepage    = 'http://github.com/snusnu/dm-accepts_nested_attributes'
    gem.authors     = [ 'Martin Gamsjaeger' ]

    gem.add_dependency 'dm-core', '~> 0.10.2'

    gem.add_development_dependency 'rspec', '~> 1.2.9'
    gem.add_development_dependency 'yard',  '~> 0.4.0'

  end

  Jeweler::GemcutterTasks.new

  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = 'yardoc'
  end

rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
