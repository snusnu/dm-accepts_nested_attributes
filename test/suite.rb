require File.expand_path('../minitest_helper', __FILE__)

Dir["#{Dir.pwd}/**/*.rb"].each { |test| require test }
