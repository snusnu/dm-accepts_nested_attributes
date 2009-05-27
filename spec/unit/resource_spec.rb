require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Resource do
  
  before(:all) do
    DataMapper.auto_migrate!
  end
  
  describe "class methods:" do
  
    describe "reject_new_nested_attributes_guard_for(association_name)" do
    
      it "should be available" do
        Person.respond_to?(:reject_new_nested_attributes_guard_for).should be_true
      end
    
      it "should return the proc that has been stored for the association named association_name" do
        guard = lambda { |attributes| true }
        Person.accepts_nested_attributes_for :profile, :reject_if => guard
        Person.reject_new_nested_attributes_guard_for(:profile).should == guard
      end
        
      it "should return nil if association_name is nil" do
        Person.reject_new_nested_attributes_guard_for(nil).should be_nil
      end
            
      it "should return nil if association_name is no valid association" do
        Person.reject_new_nested_attributes_guard_for(:foo).should be_nil
      end
    
    end
  
    describe "relationship(name)" do
    
      it "should raise when passed no name" do
        lambda { Person.relationship }.should raise_error(ArgumentError)
      end
        
      it "should raise when passed nil as name" do
        lambda { Person.relationship(nil) }.should raise_error(ArgumentError)
      end
            
      it "should raise when there is no association named name" do
        lambda { Person.relationship(:foo) }.should raise_error(ArgumentError)
      end
                    
      it "should not raise when there is an association named name" do
        lambda { Person.relationship(:profile) }.should_not raise_error
      end
    
      it "should return an instance of DataMapper::Associations::Relationship when there is an association named name" do
        Person.relationship(:profile).is_a?(DataMapper::Associations::Relationship).should be_true
      end
    
    end
    
  end
  
end