require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::NestedAttributes do
  
  describe "every accessible belongs_to association", :shared => true do
  
    it "should allow to create a new person via Profile#person_attributes" do
      @profile.person_attributes = { :name => 'Martin' }
      @profile.person.should_not be_nil
      @profile.person.name.should == 'Martin'
      @profile.save
      @profile.person.should == Person.first
      Profile.all.size.should == 1
      Person.all.size.should == 1
      Person.first.name.should == 'Martin'
    end
      
    it "should allow to update an existing person via Profile#person_attributes" do
      person = Person.create(:name => 'Martin')
      @profile.person = person
      @profile.save
    
      Person.all.size.should == 1
      Person.first.name.should == 'Martin'
      Profile.all.size.should == 1
    
      @profile.person.should == person
      @profile.person_attributes = { :id => person.id, :name => 'Martin Gamsjaeger' }
      @profile.person.name.should == 'Martin Gamsjaeger'
      @profile.save
    
      Person.all.size.should == 1
      Person.first.name.should == 'Martin Gamsjaeger'
      Profile.all.size.should == 1
    end
  
  end

  describe "Profile.belongs_to(:person)" do
  
    describe "accepts_nested_attributes_for(:person, :allow_destroy = false)" do
    
      before(:each) do
        DataMapper.auto_migrate!
        Profile.accepts_nested_attributes_for :person
        @profile = Profile.new :nick => 'snusnu'
      end
    
      it_should_behave_like "every accessible belongs_to association"
      
      it "should not allow to delete an existing person via Profile#person_attributes" do
        person = Person.create(:name => 'Martin')
        @profile.person = person
        @profile.save
        
        Profile.all.size.should == 1
        Person.all.size.should == 1
      
        @profile.person_attributes = { :id => person.id, :_delete => true }
        @profile.save
        
        Profile.all.size.should == 1
        Person.all.size.should == 1
      end
    
    end
      
    describe "accepts_nested_attributes_for(:person, :allow_destroy = true)" do
    
      before(:each) do
        DataMapper.auto_migrate!
        Profile.accepts_nested_attributes_for :person, :allow_destroy => true
        @profile = Profile.new :nick => 'snusnu'
      end
    
      it_should_behave_like "every accessible belongs_to association"
      
      it "should allow to delete an existing person via Profile#person_attributes" do
        person = Person.create(:name => 'Martin')
        @profile.person = person
        @profile.save
        
        Profile.all.size.should == 1
        Person.all.size.should == 1
      
        @profile.person_attributes = { :id => person.id, :_delete => true }
        @profile.save
        
        Profile.all.size.should == 1
        Person.all.size.should == 0
      end
    
    end

  end
  
end