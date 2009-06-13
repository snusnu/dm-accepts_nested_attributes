require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::NestedAttributes do

  describe "Person.has(1, :profile)" do
    
    include XToOneHelpers
    
    before(:all) do
      DataMapper.auto_migrate!
    end
    
    describe "accepts_nested_attributes_for(:profile)" do
    
      before(:each) do
        clear_data
        Person.accepts_nested_attributes_for :profile
        @person = Person.new :name => 'Martin'
      end

      it_should_behave_like "every accessible has(1) association"
      it_should_behave_like "every accessible has(1) association with no reject_if proc"
      it_should_behave_like "every accessible has(1) association with :allow_destroy => false"
      it_should_behave_like "every accessible has(1) association with a nested attributes reader"
      
    end
        
    describe "accepts_nested_attributes_for(:profile, :allow_destroy => false)" do
    
      before(:each) do
        clear_data
        Person.accepts_nested_attributes_for :profile, :allow_destroy => false
        @person = Person.new :name => 'Martin'
      end

      it_should_behave_like "every accessible has(1) association"
      it_should_behave_like "every accessible has(1) association with no reject_if proc"
      it_should_behave_like "every accessible has(1) association with :allow_destroy => false"
      it_should_behave_like "every accessible has(1) association with a nested attributes reader"
      
    end
    
    describe "accepts_nested_attributes_for(:profile, :allow_destroy => true)" do
      
      before(:each) do
        clear_data
        Person.accepts_nested_attributes_for :profile, :allow_destroy => true
        @person = Person.new :name => 'Martin'
      end

      it_should_behave_like "every accessible has(1) association"
      it_should_behave_like "every accessible has(1) association with no reject_if proc"
      it_should_behave_like "every accessible has(1) association with :allow_destroy => true"
      it_should_behave_like "every accessible has(1) association with a nested attributes reader"
      
    end
    
    
    describe "accepts_nested_attributes_for :profile, " do
            
      describe ":reject_if => lambda { |attrs| true }" do
    
        before(:each) do
          clear_data
          Person.accepts_nested_attributes_for :profile, :reject_if => lambda { |attrs| true }
          @person = Person.new :name => 'Martin'
        end

        it_should_behave_like "every accessible has(1) association"
        it_should_behave_like "every accessible has(1) association with a valid reject_if proc"
        it_should_behave_like "every accessible has(1) association with :allow_destroy => false"
        it_should_behave_like "every accessible has(1) association with a nested attributes reader"
      
      end
      
      describe ":reject_if => lambda { |attrs| false }" do
        
        before(:each) do
          clear_data
          Person.accepts_nested_attributes_for :profile, :reject_if => lambda { |attrs| false }
          @person = Person.new :name => 'Martin'
        end

        it_should_behave_like "every accessible has(1) association"
        it_should_behave_like "every accessible has(1) association with no reject_if proc"
        it_should_behave_like "every accessible has(1) association with :allow_destroy => false"
        it_should_behave_like "every accessible has(1) association with a nested attributes reader"
      
      end
    
    end
    
  
  end
  
end
