require 'pathname'
require 'spec'

# require the plugin
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-accepts_nested_attributes'

# allow testing with dm-validations enabled
# must be required after the plugin, since
# dm-validations seems to need dm-core
require 'dm-validations'
require 'dm-constraints'

ENV["SQLITE3_SPEC_URI"]  ||= 'sqlite3::memory:'
ENV["MYSQL_SPEC_URI"]    ||= 'mysql://localhost/dm-accepts_nested_attributes_test'
ENV["POSTGRES_SPEC_URI"] ||= 'postgres://postgres@localhost/dm-accepts_nested_attributes_test'
 
 
def setup_adapter(name, default_uri = nil)
  begin
    DataMapper.setup(name, ENV["#{ENV['ADAPTER'].to_s.upcase}_SPEC_URI"] || default_uri)
    Object.const_set('ADAPTER', ENV['ADAPTER'].to_sym) if name.to_s == ENV['ADAPTER']
    true
  rescue Exception => e
    if name.to_s == ENV['ADAPTER']
      Object.const_set('ADAPTER', nil)
      warn "Could not load do_#{name}: #{e}"
    end
    false
  end
end

ENV['ADAPTER'] ||= 'mysql'
setup_adapter(:default)

spec_dir = Pathname(__FILE__).dirname.to_s
Dir[ spec_dir + "/lib/**/*.rb"      ].each { |rb| require(rb) }
Dir[ spec_dir + "/fixtures/**/*.rb" ].each { |rb| require(rb) }
Dir[ spec_dir + "/shared/**/*.rb"   ].each { |rb| require(rb) }


module XToOneHelpers
  
  def clear_data
    Profile.all.destroy!
    Person.all.destroy!
  end
  
end

module OneToManyHelpers
  
  def clear_data
    Task.all.destroy!
    Project.all.destroy!
  end
  
end

module ManyToManyHelpers
  
  def clear_data
    ProjectMembership.all.destroy!
    Project.all.destroy!
    Person.all.destroy!
  end
  
end