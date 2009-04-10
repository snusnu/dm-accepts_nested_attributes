# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'dm-core',          '>=0.9.11'
gem 'dm-validations',   '>=0.9.11'

require 'dm-core'
require 'dm-validations'

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'dm-accepts_nested_attributes' / 'nested_attributes'
# monkeypatches for dm-core/associations/(many_to_one.rb and one_to_many.rb)
require Pathname(__FILE__).dirname.expand_path / 'dm-accepts_nested_attributes' / 'associations'

# Include the plugin in Model
DataMapper::Resource.append_inclusions DataMapper::NestedAttributes
