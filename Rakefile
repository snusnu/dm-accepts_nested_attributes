require 'pathname'
require 'rake'
require 'rake/rdoctask'

ROOT = Pathname(__FILE__).dirname.expand_path
JRUBY = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform?
SUDO = (WINDOWS || JRUBY) ? '' : ('sudo' unless ENV['SUDOLESS'])

require ROOT + 'lib/dm-accepts_nested_attributes/version'

AUTHOR = "Martin Gamsjäger"
EMAIL  = "gamsnjaga [a] gmail [d] com"
GEM_NAME = "dm-accepts_nested_attributes"
GEM_VERSION = DataMapper::NestedAttributes::VERSION

GEM_DEPENDENCIES = [
  ["dm-core",        '>=0.10.0'],
  ["dm-validations", '>=0.10.0']
]

GEM_CLEAN = %w[ log pkg coverage ]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.textile LICENSE TODO History.txt ] }

PROJECT_NAME = "dm-accepts_nested_attributes"
PROJECT_URL  = "http://github.com/snusnu/dm-accepts_nested_attributes/tree/master"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = %{
A DataMapper plugin that adds the possibility to perform nested model attribute assignment
}

Pathname.glob(ROOT.join('tasks/**/*.rb').to_s).each { |f| require f }
