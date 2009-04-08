# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'dm-core',          '>=0.9.11'
gem 'dm-validations',   '>=0.9.11'

require 'dm-core'
require 'dm-validations'

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'dm-accepts_nested_attributes' / 'nested_attributes.rb'
require Pathname(__FILE__).dirname.expand_path / 'dm-accepts_nested_attributes' / 'autosave_association.rb'

# Include the plugin in Model
DataMapper::Resource.append_inclusions DataMapper::NestedAttributes
DataMapper::Resource.append_inclusions DataMapper::AutosaveAssociation
