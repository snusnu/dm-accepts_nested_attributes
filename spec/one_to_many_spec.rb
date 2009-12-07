require 'spec_helper'

describe "Project.has(n, :tasks);" do

  before(:all) do

    class Project

      include DataMapper::Resource
      extend ConstraintSupport

      property :id,   Serial
      property :name, String, :required => true

      has n, :tasks, constraint(:destroy)

    end

    class Task

      include DataMapper::Resource

      property :id,   Serial
      property :name, String,  :required => true

      belongs_to :project

    end

    DataMapper.auto_upgrade!

  end

  before(:each) do
    Task.all.destroy!
    Project.all.destroy!
  end


  describe "Project.accepts_nested_attributes_for(:tasks)" do

    before(:all) do
      Project.accepts_nested_attributes_for :tasks
    end

    it_should_behave_like "every accessible one_to_many association"
    it_should_behave_like "every accessible one_to_many association with no reject_if proc"
    it_should_behave_like "every accessible one_to_many association with :allow_destroy => false"

  end

  describe "Project.accepts_nested_attributes_for(:tasks, :allow_destroy => false)" do

    before(:all) do
      Project.accepts_nested_attributes_for :tasks, :allow_destroy => false
    end

    it_should_behave_like "every accessible one_to_many association"
    it_should_behave_like "every accessible one_to_many association with no reject_if proc"
    it_should_behave_like "every accessible one_to_many association with :allow_destroy => false"

  end

  describe "Project.accepts_nested_attributes_for(:tasks, :allow_destroy => true)" do

    before(:all) do
      Project.accepts_nested_attributes_for :tasks, :allow_destroy => true
    end

    it_should_behave_like "every accessible one_to_many association"
    it_should_behave_like "every accessible one_to_many association with no reject_if proc"
    it_should_behave_like "every accessible one_to_many association with :allow_destroy => true"

  end

  describe "Project.accepts_nested_attributes_for(:tasks, :reject_if => lambda { |attrs| true })" do

    before(:all) do
      Project.accepts_nested_attributes_for :tasks, :reject_if => lambda { |attrs| true }
    end

    it_should_behave_like "every accessible one_to_many association"
    it_should_behave_like "every accessible one_to_many association with a valid reject_if proc"
    it_should_behave_like "every accessible one_to_many association with :allow_destroy => false"

  end

  describe "Project.accepts_nested_attributes_for(:tasks, :reject_if => lambda { |attrs| false })" do

    before(:all) do
      Project.accepts_nested_attributes_for :tasks, :reject_if => lambda { |attrs| false }
    end

    it_should_behave_like "every accessible one_to_many association"
    it_should_behave_like "every accessible one_to_many association with no reject_if proc"
    it_should_behave_like "every accessible one_to_many association with :allow_destroy => false"

  end

end
