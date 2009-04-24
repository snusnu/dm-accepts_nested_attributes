desc "Generate gemspec"
task :gemspec do |x|
  
  %x[rake debug_gem > #{GEM_NAME}.gemspec]
  puts "Successfully created gemspec for #{GEM_NAME}!"
  
end