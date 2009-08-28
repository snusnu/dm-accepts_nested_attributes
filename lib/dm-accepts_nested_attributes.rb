require 'pathname'
require 'dm-core'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-accepts_nested_attributes'

require dir / 'model'
require dir / 'resource'

# Activate the plugin
DataMapper::Model.append_extensions(DataMapper::NestedAttributes::Model)
