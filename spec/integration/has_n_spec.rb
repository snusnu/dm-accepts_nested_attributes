require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::NestedAttributes do

  describe "Project.has(n, :tasks)" do

    include OneToManyHelpers

    before(:all) do
      DataMapper.auto_migrate!
    end

    describe "accepts_nested_attributes_for(:tasks)" do

      before(:each) do
        clear_data
        Project.accepts_nested_attributes_for :tasks
        @project = Project.new :name => 'trippings'
      end

      it_should_behave_like "every accessible has(n) association"
      it_should_behave_like "every accessible has(n) association with no reject_if proc"
      it_should_behave_like "every accessible has(n) association with :allow_destroy => false"

    end

    describe "accepts_nested_attributes_for(:tasks, :allow_destroy => false)" do

      before(:each) do
        clear_data
        Project.accepts_nested_attributes_for :tasks, :allow_destroy => false
        @project = Project.new :name => 'trippings'
      end

      it_should_behave_like "every accessible has(n) association"
      it_should_behave_like "every accessible has(n) association with no reject_if proc"
      it_should_behave_like "every accessible has(n) association with :allow_destroy => false"

    end

    describe "accepts_nested_attributes_for(:tasks, :allow_destroy => true)" do

      before(:each) do
        clear_data
        Project.accepts_nested_attributes_for :tasks, :allow_destroy => true
        @project = Project.new :name => 'trippings'
      end

      it_should_behave_like "every accessible has(n) association"
      it_should_behave_like "every accessible has(n) association with no reject_if proc"
      it_should_behave_like "every accessible has(n) association with :allow_destroy => true"

    end

    describe "accepts_nested_attributes_for :tasks, " do

      describe ":reject_if => lambda { |attrs| true }" do

        before(:each) do
          clear_data
          Project.accepts_nested_attributes_for :tasks, :reject_if => lambda { |attrs| true }
          @project = Project.new :name => 'trippings'
        end

        it_should_behave_like "every accessible has(n) association"
        it_should_behave_like "every accessible has(n) association with a valid reject_if proc"
        it_should_behave_like "every accessible has(n) association with :allow_destroy => false"

      end

      describe ":reject_if => lambda { |attrs| false }" do

        before(:each) do
          clear_data
          Project.accepts_nested_attributes_for :tasks, :reject_if => lambda { |attrs| false }
          @project = Project.new :name => 'trippings'
        end

        it_should_behave_like "every accessible has(n) association"
        it_should_behave_like "every accessible has(n) association with no reject_if proc"
        it_should_behave_like "every accessible has(n) association with :allow_destroy => false"

      end

    end

  end

end
