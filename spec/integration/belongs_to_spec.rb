require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::NestedAttributes do

  
  describe "every accessible belongs_to association with no associated parent model", :shared => true do
    
    it "should return a new_record from get_\#{association_name}" do
      @profile.person_attributes = { :name => 'Martin' }
      @profile.get_person.should_not be_nil
      @profile.get_person.should be_new_record
    end
    
  end
  
  describe "every accessible belongs_to association with an associated parent model", :shared => true do

    it "should return an already existing record from get_\#{association_name}" do
      @profile.person_attributes = { :name => 'Martin' }
      @profile.save
      @profile.get_person.should_not be_nil
      @profile.get_person.should_not be_new_record
      @profile.get_person.should be_kind_of(Person)
    end
  
  end
    
  describe "every accessible belongs_to association with a valid reject_if proc", :shared => true do
    
    it_should_behave_like "every accessible belongs_to association with no associated parent model"
  
    it "should not allow to create a new person via Profile#person_attributes" do
      @profile.person_attributes = { :name => 'Martin' }
      @profile.person.should be_nil
      @profile.save
      Profile.all.size.should == 1
      Person.all.size.should == 0
    end
    
  end
    
  describe "every accessible belongs_to association with no reject_if proc", :shared => true do
    
    it_should_behave_like "every accessible belongs_to association with no associated parent model"
    it_should_behave_like "every accessible belongs_to association with an associated parent model"
  
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
  
  describe "every accessible belongs_to association with :allow_destroy => false", :shared => true do
    
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
    
  describe "every accessible belongs_to association with :allow_destroy => true", :shared => true do
    
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

  describe "Profile.belongs_to(:person)" do
  
    describe "accepts_nested_attributes_for(:person)" do
    
      before(:each) do
        DataMapper.auto_migrate!
        Profile.accepts_nested_attributes_for :person
        @profile = Profile.new :nick => 'snusnu'
      end
      
      it_should_behave_like "every accessible belongs_to association with no reject_if proc"
      it_should_behave_like "every accessible belongs_to association with :allow_destroy => false"
    
    end
      
    describe "accepts_nested_attributes_for(:person, :allow_destroy => false)" do
    
      before(:each) do
        DataMapper.auto_migrate!
        Profile.accepts_nested_attributes_for :person, :allow_destroy => false
        @profile = Profile.new :nick => 'snusnu'
      end
      
      it_should_behave_like "every accessible belongs_to association with no reject_if proc"
      it_should_behave_like "every accessible belongs_to association with :allow_destroy => false"
    
    end
      
    describe "accepts_nested_attributes_for(:person, :allow_destroy = true)" do
    
      before(:each) do
        DataMapper.auto_migrate!
        Profile.accepts_nested_attributes_for :person, :allow_destroy => true
        @profile = Profile.new :nick => 'snusnu'
      end
      
      it_should_behave_like "every accessible belongs_to association with no reject_if proc"
      it_should_behave_like "every accessible belongs_to association with :allow_destroy => true"
    
    end
          
    describe "accepts_nested_attributes_for :person, " do
      
      describe ":reject_if => :foo" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Profile.accepts_nested_attributes_for :person, :reject_if => :foo
          @profile = Profile.new :nick => 'snusnu'
        end
        
        it_should_behave_like "every accessible belongs_to association with no reject_if proc"
        it_should_behave_like "every accessible belongs_to association with :allow_destroy => false"
      
      end
            
      describe ":reject_if => lambda { |attrs| true }" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Profile.accepts_nested_attributes_for :person, :reject_if => lambda { |attrs| true }
          @profile = Profile.new :nick => 'snusnu'
        end
        
        it_should_behave_like "every accessible belongs_to association with a valid reject_if proc"
        it_should_behave_like "every accessible belongs_to association with :allow_destroy => false"
      
      end
                  
      describe ":reject_if => lambda { |attrs| false }" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Profile.accepts_nested_attributes_for :person, :reject_if => lambda { |attrs| false }
          @profile = Profile.new :nick => 'snusnu'
        end
    
        it_should_behave_like "every accessible belongs_to association with no reject_if proc"
        it_should_behave_like "every accessible belongs_to association with :allow_destroy => false"
      
      end
    
    end

  end
  
end