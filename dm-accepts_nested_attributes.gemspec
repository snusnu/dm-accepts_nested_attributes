# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-accepts_nested_attributes}
  s.version = "0.11.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Martin Gamsj\303\244ger"]
  s.date = %q{2009-06-25}
  s.description = %q{
A DataMapper plugin that adds the possibility to perform nested model attribute assignment
}
  s.email = ["gamsnjaga [a] gmail [d] com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = [".gitignore", "History.txt", "LICENSE", "Manifest.txt", "README.textile", "Rakefile", "TODO", "CHANGELOG", "lib/dm-accepts_nested_attributes.rb", "lib/dm-accepts_nested_attributes/error_collecting.rb", "lib/dm-accepts_nested_attributes/model.rb", "lib/dm-accepts_nested_attributes/resource.rb", "lib/dm-accepts_nested_attributes/transactional_save.rb", "lib/dm-accepts_nested_attributes/version.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/lib/constraint_support.rb", "spec/fixtures/person.rb", "spec/fixtures/profile.rb", "spec/fixtures/project.rb", "spec/fixtures/project_membership.rb", "spec/fixtures/task.rb", "spec/shared/belongs_to_spec.rb", "spec/shared/has_1_spec.rb", "spec/shared/has_n_spec.rb", "spec/shared/has_n_through_spec.rb", "spec/unit/accepts_nested_attributes_for_spec.rb", "spec/integration/belongs_to_spec.rb", "spec/integration/has_1_spec.rb", "spec/integration/has_n_spec.rb", "spec/integration/has_n_through_spec.rb", "tasks/changelog.rb", "tasks/gemspec.rb", "tasks/hoe.rb", "tasks/install.rb", "tasks/spec.rb"]
  s.homepage = %q{http://github.com/snusnu/dm-accepts_nested_attributes/tree/master}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dm-accepts_nested_attributes}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{A DataMapper plugin that adds the possibility to perform nested model attribute assignment}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, [">= 0.10.0"])
      s.add_runtime_dependency(%q<dm-validations>, [">= 0.10.0"])
    else
      s.add_dependency(%q<dm-core>, [">= 0.10.0"])
      s.add_dependency(%q<dm-validations>, [">= 0.10.0"])
    end
  else
    s.add_dependency(%q<dm-core>, [">= 0.10.0"])
    s.add_dependency(%q<dm-validations>, [">= 0.10.0"])
  end
end
