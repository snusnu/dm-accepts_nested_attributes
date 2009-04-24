require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Resource do
  
  before(:all) do
    DataMapper.auto_migrate!
  end
  
  describe ".reject_new_nested_attributes_proc_for(association_name)" do
    
    it "should be available" do
      Person.respond_to?(:reject_new_nested_attributes_proc_for).should be_true
    end
    
    it "should return the proc that has been stored for the association named association_name" do
      guard = lambda { |attributes| true }
      Person.accepts_nested_attributes_for :profile, :reject_if => guard
      Person.reject_new_nested_attributes_proc_for(:profile).should == guard
    end
        
    it "should return nil if association_name is nil" do
      Person.reject_new_nested_attributes_proc_for(nil).should be_nil
    end
            
    it "should return nil if association_name is no valid association" do
      Person.reject_new_nested_attributes_proc_for(:foo).should be_nil
    end
    
  end
  
  describe ".association_for_name(name)" do
    
    it "should raise when passed no name" do
      lambda { Person.association_for_name }.should raise_error(ArgumentError)
    end
        
    it "should raise when passed nil as name" do
      lambda { Person.association_for_name(nil) }.should raise_error(ArgumentError)
    end
            
    it "should raise when there is no association named name" do
      lambda { Person.association_for_name(:foo) }.should raise_error(ArgumentError)
    end
                    
    it "should not raise when there is an association named name" do
      lambda { Person.association_for_name(:profile) }.should_not raise_error
    end
    
    it "should return an instance of DataMapper::Associations::Relationship when there is an association named name" do
      Person.association_for_name(:profile).is_a?(DataMapper::Associations::Relationship).should be_true
    end
    
  end
        
  describe ".associated_model_for_name(association_name)" do
    
    it "should raise when passed no association_name" do
      lambda { Person.associated_model_for_name }.should raise_error(ArgumentError)
    end
        
    it "should raise when passed nil as association_name" do
      lambda { Person.associated_model_for_name(nil) }.should raise_error(ArgumentError)
    end
            
    it "should raise when there is no association named association_name" do
      lambda { Person.associated_model_for_name(:foo) }.should raise_error(ArgumentError)
    end
    
    it "should not raise when there is an association named association_name" do
      lambda { Person.associated_model_for_name(:profile) }.should_not raise_error
    end
    
    describe "and association_name points to a has(1) association" do
            
      it "should return the class of the associated model when the association named association_name is present" do
        Person.associated_model_for_name(:profile).should == Profile
      end
      
    end
        
    describe "and association_name points to a has(n) association" do
            
      it "should return the class of the associated model when the association named association_name is present" do
        Person.associated_model_for_name(:project_memberships).should == ProjectMembership
      end
      
    end
            
    describe "and association_name points to a has(n, :through) association" do
            
      it "should return the class of the associated model when the association named association_name is present" do
        Person.associated_model_for_name(:projects).should == Project
      end
      
    end
                
    describe "and association_name points to a belongs_to association" do
            
      it "should return the class of the associated model when the association named association_name is present" do
        Profile.associated_model_for_name(:person).should == Person
      end
      
    end
    
  end
  
  describe ".nr_of_possible_child_instances(assocation_name)" do
    
    it "should raise when passed no association_name" do
      lambda { Person.nr_of_possible_child_instances }.should raise_error(ArgumentError)
    end
        
    it "should raise when passed nil as association_name" do
      lambda { Person.nr_of_possible_child_instances(nil) }.should raise_error(ArgumentError)
    end
            
    it "should raise when there is no association named association_name" do
      lambda { Person.nr_of_possible_child_instances(:foo) }.should raise_error(ArgumentError)
    end
    
    it "should not raise when there is an association named association_name" do
      lambda { Person.nr_of_possible_child_instances(:profile) }.should_not raise_error
    end

    it "should return 1 for a belongs_to relation" do
      Profile.nr_of_possible_child_instances(:person).should == 1
    end

    it "should return 1 for a has(1) relation" do
      Person.nr_of_possible_child_instances(:profile).should == 1
    end

    it "should return Infinity for a has(n) relation" do
      Person.nr_of_possible_child_instances(:project_memberships).should == Person.n
    end

    it "should return Infinity for a has(n, :through) relation" do
      Person.nr_of_possible_child_instances(:projects).should == Person.n
    end

  end
  
  describe "#associated_instance_get(association_name)" do
    
    before(:each) do
      @person = Person.create(:name => 'snusnu')
      @person.profile = Profile.new
      @person.save
    end
  
    it "should raise when passed no association_name" do
      lambda { @person.associated_instance_get }.should raise_error
    end
      
    it "should raise when passed nil as association_name" do
      lambda { @person.associated_instance_get(nil) }.should raise_error
    end
          
    it "should raise when there is no association named association_name" do
      lambda { @person.associated_instance_get(:foo) }.should raise_error
    end
    
    it "should return an object that has the same class like the associated resource" do
      @person.associated_instance_get(:profile).class.should == Profile
    end
                  
    it "should return the associated object when there is an association named association_name" do
      @person.associated_instance_get(:profile).should == @person.profile
    end
  
  end
  
end