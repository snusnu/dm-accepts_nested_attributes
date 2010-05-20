require 'spec_helper'

describe "Person.has(n, :projects, :through => :project_memberships);" do

  before(:all) do

    class ::Person

      include DataMapper::Resource
      extend ConstraintSupport

      property :id,   Serial
      property :name, String, :required => true

      has n, :project_memberships, constraint(:destroy)
      has n, :projects, :through => :project_memberships
      has n, :tasks, :through => :projects

    end

    class ::Project

      include DataMapper::Resource
      extend ConstraintSupport

      property :id,   Serial
      property :name, String, :required => true

      has n, :project_memberships, constraint(:destroy)
      has n, :people, :through => :project_memberships
      has n, :tasks, constraint(:destroy)

    end

    class ::ProjectMembership

      include DataMapper::Resource

      property :id,         Serial

      belongs_to :person
      belongs_to :project

    end

    class ::Task

      include DataMapper::Resource

      property :id,   Serial
      property :name, String,  :required => true

      belongs_to :project

    end

    DataMapper.auto_migrate!

  end

  before(:each) do
    ProjectMembership.all.destroy!
    Task.all.destroy!
    Project.all.destroy!
    Person.all.destroy!
  end


  describe "Person.accepts_nested_attributes_for(:projects)" do

    before(:all) do
      Person.accepts_nested_attributes_for :projects
    end

    it_should_behave_like "every accessible many_to_many association"
    it_should_behave_like "every accessible many_to_many association with no reject_if proc"
    it_should_behave_like "every accessible many_to_many association with :allow_destroy => false"

  end

  describe "Person.accepts_nested_attributes_for(:projects, :allow_destroy => false)" do

    before(:all) do
      Person.accepts_nested_attributes_for :projects, :allow_destroy => false
    end

    it_should_behave_like "every accessible many_to_many association"
    it_should_behave_like "every accessible many_to_many association with no reject_if proc"
    it_should_behave_like "every accessible many_to_many association with :allow_destroy => false"

  end

  describe "Person.accepts_nested_attributes_for(:projects, :allow_destroy = true)" do

    before(:all) do
      Person.accepts_nested_attributes_for :projects, :allow_destroy => true
    end

    it_should_behave_like "every accessible many_to_many association"
    it_should_behave_like "every accessible many_to_many association with no reject_if proc"
    it_should_behave_like "every accessible many_to_many association with :allow_destroy => true"

  end

  describe "Person.accepts_nested_attributes_for(:projects, :reject_if => lambda { |attrs| true })" do

    before(:all) do
      Person.accepts_nested_attributes_for :projects, :reject_if => lambda { |attrs| true }
    end

    it_should_behave_like "every accessible many_to_many association"
    it_should_behave_like "every accessible many_to_many association with a valid reject_if proc"
    it_should_behave_like "every accessible many_to_many association with :allow_destroy => false"

  end

  describe "Person.accepts_nested_attributes_for(:projects, :reject_if => lambda { |attrs| false })" do

    before(:all) do
      Person.accepts_nested_attributes_for :projects, :reject_if => lambda { |attrs| false }
    end

    it_should_behave_like "every accessible many_to_many association"
    it_should_behave_like "every accessible many_to_many association with no reject_if proc"
    it_should_behave_like "every accessible many_to_many association with :allow_destroy => false"

  end

end
