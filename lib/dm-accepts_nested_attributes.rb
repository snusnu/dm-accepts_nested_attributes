require 'dm-core'

require 'data_mapper/nested_attributes/version'

require 'data_mapper/nested_attributes/model'
require 'data_mapper/nested_attributes/resource'
require 'data_mapper/nested_attributes/acceptor'
require 'data_mapper/nested_attributes/assignment'
require 'data_mapper/nested_attributes/assignment/guard'
require 'data_mapper/nested_attributes/key_values_extractor'
require 'data_mapper/nested_attributes/updater'

# Activate the plugin
DataMapper::Model.append_extensions(DataMapper::NestedAttributes::Model)
