require 'pathname'
require 'rubygems'
 
gem 'rspec', '>=1.1.12'
require 'spec'
 
gem 'dm-core', '0.9.11'
require 'dm-core'
 
gem 'dm-validations', '0.9.11'
require 'dm-validations'
 
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-accepts_nested_attributes'
 
ENV["SQLITE3_SPEC_URI"]  ||= 'sqlite3::memory:'
ENV["MYSQL_SPEC_URI"]    ||= 'mysql://localhost/dm_core_test'
ENV["POSTGRES_SPEC_URI"] ||= 'postgres://postgres@localhost/dm_more_test'

module DataMapper
  class TextmateRspecLogger < Logger
    def prep_msg(message, level)
      "#{super}<br />"
    end
  end
end
 
# DataMapper::TextmateRspecLogger.new(STDOUT, :debug)
 
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
 
ENV['ADAPTER'] ||= 'sqlite3'
 
setup_adapter(:default)
Dir[Pathname(__FILE__).dirname.to_s + "/fixtures/**/*.rb"].each { |rb| require(rb) }