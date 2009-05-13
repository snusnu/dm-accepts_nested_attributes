# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-accepts_nested_attributes}
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Martin Gamsj\303\244ger"]
  s.date = %q{2009-05-13}
  s.description = %q{
A DataMapper plugin that adds the possibility to perform nested model attribute assignment
}
  s.email = ["gamsnjaga [a] gmail [d] com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = [".gitignore", "History.txt", "LICENSE", "Manifest.txt", "README.textile", "Rakefile", "TODO", "CHANGELOG", "lib/dm-accepts_nested_attributes.rb", "lib/dm-accepts_nested_attributes/association_proxies.rb", "lib/dm-accepts_nested_attributes/association_validation.rb", "lib/dm-accepts_nested_attributes/nested_attributes.rb", "lib/dm-accepts_nested_attributes/resource.rb", "lib/dm-accepts_nested_attributes/version.rb", "spec/fixtures/person.rb", "spec/fixtures/profile.rb", "spec/fixtures/project.rb", "spec/fixtures/project_membership.rb", "spec/fixtures/task.rb", "spec/integration/belongs_to_spec.rb", "spec/integration/has_1_spec.rb", "spec/integration/has_n_spec.rb", "spec/integration/has_n_through_spec.rb", "spec/shared/rspec_tmbundle_support.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit/accepts_nested_attributes_for_spec.rb", "spec/unit/resource_spec.rb", "tasks/gemspec.rb", "tasks/hoe.rb", "tasks/install.rb", "tasks/spec.rb"]
  s.homepage = %q{http://github.com/snusnu/dm-accepts_nested_attributes/tree/master}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dm-accepts_nested_attributes}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{A DataMapper plugin that adds the possibility to perform nested model attribute assignment}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, [">= 0.9.11"])
      s.add_runtime_dependency(%q<addressable>, ["~> 2.0.2"])
    else
      s.add_dependency(%q<dm-core>, [">= 0.9.11"])
      s.add_dependency(%q<addressable>, ["~> 2.0.2"])
    end
  else
    s.add_dependency(%q<dm-core>, [">= 0.9.11"])
    s.add_dependency(%q<addressable>, ["~> 2.0.2"])
  end
end
