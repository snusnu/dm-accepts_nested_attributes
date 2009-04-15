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

# -----------------------------------------------
# support for nice html output in rspec tmbundle
# -----------------------------------------------

USE_TEXTMATE_RSPEC_BUNDLE = true # set to false if not using textmate

if USE_TEXTMATE_RSPEC_BUNDLE

  require Pathname(__FILE__).dirname.expand_path + 'shared/rspec_tmbundle_support'

  # use the tmbundle logger
  RSpecTmBundleHelpers::TextmateRspecLogger.new(STDOUT, :off)
  

  class Object
    include RSpecTmBundleHelpers
  end

end

ENV['ADAPTER'] ||= 'sqlite3'
setup_adapter(:default)
Dir[Pathname(__FILE__).dirname.to_s + "/fixtures/**/*.rb"].each { |rb| require(rb) }
