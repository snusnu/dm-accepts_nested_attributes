require 'dm-core'

require 'dm-accepts_nested_attributes/model'
require 'dm-accepts_nested_attributes/resource'

# Activate the plugin
DataMapper::Model.append_extensions(DataMapper::NestedAttributes::Model)
