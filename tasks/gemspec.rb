desc "Generate gemspec"
task :gemspec do |x|
  
  # # Clean up extraneous files before checking manifest
  # %x[rake clean]
 
  %x[rake debug_gem > #{GEM_NAME}.gemspec]
  puts "Successfully created gemspec for #{GEM_NAME}!"
  
end