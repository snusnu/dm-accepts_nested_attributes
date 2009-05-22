require 'pathname'

require 'dm-core'
require 'dm-validations'

# Require plugin-files
dir = Pathname(__FILE__).dirname.expand_path / 'dm-accepts_nested_attributes'
require dir / 'support'
require dir / 'model'
require dir / 'resource'
require dir / 'association_proxies'

# Include the plugin in Model
DataMapper::Model.append_extensions DataMapper::NestedAttributes::Model
DataMapper::Model.append_inclusions DataMapper::NestedAttributes::CommonResourceSupport
