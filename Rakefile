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
    gem.has_rdoc    = 'yard'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }

rescue LoadError => e
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
  puts '-----------------------------------------------------------------------------'
  puts e.backtrace # Let's help by actually showing *which* dependency is missing
end
