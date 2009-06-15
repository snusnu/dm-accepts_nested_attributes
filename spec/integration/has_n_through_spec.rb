require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::NestedAttributes do

  describe "Person.has(n, :projects, :through => :project_memberships)" do
    
    include ManyToManyHelpers
    
    before(:all) do
      DataMapper.auto_migrate!
    end
  
    describe "accepts_nested_attributes_for(:projects)" do
      
      before(:each) do
        clear_data
        Person.accepts_nested_attributes_for :projects
        @person = Person.new :name => 'snusnu'
      end

      it_should_behave_like "every accessible has(n, :through) association"
      it_should_behave_like "every accessible has(n, :through) association with no reject_if proc"
      it_should_behave_like "every accessible has(n, :through) association with :allow_destroy => false"
      
    end
      
    describe "accepts_nested_attributes_for(:projects, :allow_destroy => false)" do
      
      before(:each) do
        clear_data
        Person.accepts_nested_attributes_for :projects, :allow_destroy => false
        @person = Person.new :name => 'snusnu'
      end

      it_should_behave_like "every accessible has(n, :through) association"
      it_should_behave_like "every accessible has(n, :through) association with no reject_if proc"
      it_should_behave_like "every accessible has(n, :through) association with :allow_destroy => false"
      
    end
        
    describe "accepts_nested_attributes_for(:projects, :allow_destroy = true)" do
      
      before(:each) do
        clear_data
        Person.accepts_nested_attributes_for :projects, :allow_destroy => true
        @person = Person.new :name => 'snusnu'
      end

      it_should_behave_like "every accessible has(n, :through) association"
      it_should_behave_like "every accessible has(n, :through) association with no reject_if proc"
      it_should_behave_like "every accessible has(n, :through) association with :allow_destroy => true"
      
    end
    
    describe "accepts_nested_attributes_for :projects, " do
            
      describe ":reject_if => lambda { |attrs| true }" do
    
        before(:each) do
          clear_data
          Person.accepts_nested_attributes_for :projects, :reject_if => lambda { |attrs| true }
          @person = Person.new :name => 'snusnu'
        end

        it_should_behave_like "every accessible has(n, :through) association"
        it_should_behave_like "every accessible has(n, :through) association with a valid reject_if proc"
        it_should_behave_like "every accessible has(n, :through) association with :allow_destroy => false"
      
      end
                  
      describe ":reject_if => lambda { |attrs| false }" do
    
        before(:each) do
          clear_data
          Person.accepts_nested_attributes_for :projects, :reject_if => lambda { |attrs| false }
          @person = Person.new :name => 'snusnu'
        end

        it_should_behave_like "every accessible has(n, :through) association"
        it_should_behave_like "every accessible has(n, :through) association with no reject_if proc"
        it_should_behave_like "every accessible has(n, :through) association with :allow_destroy => false"
      
      end
    
    end
    
  end
  
end

