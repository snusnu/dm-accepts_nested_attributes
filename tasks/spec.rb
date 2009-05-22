begin
  gem 'rspec', '>=1.1.12'
  require 'spec'
  require 'spec/rake/spectask'
 
  task :default => [ :spec ]
 
  desc 'Run specifications'
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_opts << '--options' << 'spec/spec.opts' if File.exists?('spec/spec.opts')
    t.spec_files = [
      'spec/unit/resource_spec.rb',
      'spec/unit/accepts_nested_attributes_for_spec.rb',
      'spec/integration/belongs_to_spec.rb',
      'spec/integration/has_1_spec.rb',
      'spec/integration/has_n_spec.rb',
      'spec/integration/has_n_through_spec.rb'
    ]
 
    begin
      gem 'rcov', '~>0.8'
      t.rcov = JRUBY ? false : (ENV.has_key?('NO_RCOV') ? ENV['NO_RCOV'] != 'true' : true)
      t.rcov_opts << '--exclude' << 'spec'
      t.rcov_opts << '--text-summary'
      t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
    rescue LoadError
      # rcov not installed
    end
  end
rescue LoadError
  # rspec not installed
end