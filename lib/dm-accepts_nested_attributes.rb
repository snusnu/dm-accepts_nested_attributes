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
# monkeypatches for dm-core/associations/(many_to_one.rb and one_to_many.rb)
require Pathname(__FILE__).dirname.expand_path / 'dm-accepts_nested_attributes' / 'associations.rb'

# Include the plugin in Model
DataMapper::Resource.append_inclusions DataMapper::NestedAttributes


# TODO: remove this before release!
# helpers for development (mainly to have nice outputs in textmate's rspec bundle)

class Object

  # debugging helper
  # TODO remove before release
  def print_call_stack(from = 2, to = nil, html = false)  
    (from..(to ? to : caller.length)).each do |idx| 
      p "[#{idx}]: #{caller[idx]}#{html ? '<br />' : ''}"
    end
  end
  
  # debugging helper (textmate rspec bundle)
  # TODO remove before release
  ESCAPE_TABLE = { '&'=>'&amp;', '<'=>'&lt;', '>'=>'&gt;', '"'=>'&quot;', "'"=>'&#039;', }
  def h(value)
    value.to_s.gsub(/[&<>"]/) {|s| ESCAPE_TABLE[s] }
  end

end
