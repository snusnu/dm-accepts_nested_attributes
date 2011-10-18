require 'dm-core'

require 'data_mapper/nested_attributes/model'
require 'data_mapper/nested_attributes/resource'

# Activate the plugin
DataMapper::Model.append_extensions(DataMapper::NestedAttributes::Model)
