require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::NestedAttributes do

  describe "Profile.belongs_to(:person)" do
    
    include XToOneHelpers
    
    before(:all) do
      DataMapper.auto_migrate!
    end
  
    describe "accepts_nested_attributes_for(:person)" do
    
      before(:each) do
        clear_data
        Profile.accepts_nested_attributes_for :person
        @profile = Profile.new :nick => 'snusnu'
      end

      it_should_behave_like "every accessible belongs_to association"
      it_should_behave_like "every accessible belongs_to association with no reject_if proc"
      it_should_behave_like "every accessible belongs_to association with :allow_destroy => false"
    
    end
      
    describe "accepts_nested_attributes_for(:person, :allow_destroy => false)" do
    
      before(:each) do
        clear_data
        Profile.accepts_nested_attributes_for :person, :allow_destroy => false
        @profile = Profile.new :nick => 'snusnu'
      end

      it_should_behave_like "every accessible belongs_to association"
      it_should_behave_like "every accessible belongs_to association with no reject_if proc"
      it_should_behave_like "every accessible belongs_to association with :allow_destroy => false"
    
    end
      
    describe "accepts_nested_attributes_for(:person, :allow_destroy = true)" do
    
      before(:each) do
        clear_data
        Profile.accepts_nested_attributes_for :person, :allow_destroy => true
        @profile = Profile.new :nick => 'snusnu'
      end

      it_should_behave_like "every accessible belongs_to association"
      it_should_behave_like "every accessible belongs_to association with no reject_if proc"
      it_should_behave_like "every accessible belongs_to association with :allow_destroy => true"
    
    end
          
    describe "accepts_nested_attributes_for :person, " do
            
      describe ":reject_if => lambda { |attrs| true }" do
    
        before(:each) do
          clear_data
          Profile.accepts_nested_attributes_for :person, :reject_if => lambda { |attrs| true }
          @profile = Profile.new :nick => 'snusnu'
        end

        it_should_behave_like "every accessible belongs_to association"
        it_should_behave_like "every accessible belongs_to association with a valid reject_if proc"
        it_should_behave_like "every accessible belongs_to association with :allow_destroy => false"
      
      end
                  
      describe ":reject_if => lambda { |attrs| false }" do
    
        before(:each) do
          clear_data
          Profile.accepts_nested_attributes_for :person, :reject_if => lambda { |attrs| false }
          @profile = Profile.new :nick => 'snusnu'
        end

        it_should_behave_like "every accessible belongs_to association"
        it_should_behave_like "every accessible belongs_to association with no reject_if proc"
        it_should_behave_like "every accessible belongs_to association with :allow_destroy => false"
      
      end
    
    end

  end
  
end
