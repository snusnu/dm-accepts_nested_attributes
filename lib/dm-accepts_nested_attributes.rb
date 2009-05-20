require 'pathname'

require 'dm-core'
require 'dm-validations'

# Require plugin-files
dir = Pathname(__FILE__).dirname.expand_path / 'dm-accepts_nested_attributes'
require dir / 'resource'
require dir / 'association_proxies'
require dir / 'nested_attributes'

# Include the plugin in Model
DataMapper::Model.append_extensions DataMapper::NestedAttributes::ClassMethods
DataMapper::Resource.append_inclusions DataMapper::NestedAttributes::CommonInstanceMethods
