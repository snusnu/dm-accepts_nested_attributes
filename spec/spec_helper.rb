require 'rubygems'
require 'pathname'
require 'spec'

# require the plugin
require 'dm-accepts_nested_attributes'

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


require 'shared/many_to_many_spec'
require 'shared/many_to_one_spec'
require 'shared/one_to_many_spec'
require 'shared/one_to_one_spec'


module ConstraintSupport

  def constraint(type)
    if DataMapper.const_defined?('Constraints')
      { :constraint => type }
    else
      {}
    end
  end

end
