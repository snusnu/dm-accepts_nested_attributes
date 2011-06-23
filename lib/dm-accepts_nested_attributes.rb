require 'dm-core'

require 'dm-accepts_nested_attributes/model'
require 'dm-accepts_nested_attributes/resource'
require 'dm-accepts_nested_attributes/relationship'

# Activate the plugin
DataMapper::Model.append_extensions(DataMapper::NestedAttributes::Model)
DataMapper::Associations::Relationship.send(:include, DataMapper::NestedAttributes::Relationship)
DataMapper::Associations::ManyToMany::Relationship.send(:include, DataMapper::NestedAttributes::ManyToMany)
