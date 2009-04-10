require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::NestedAttributes do
  
  describe "every accessible has(1) association with a valid reject_if proc", :shared => true do
  
    it "should not allow to create a new profile via Person#profile_attributes" do
      @person.profile_attributes = { :nick => 'snusnu' }
      @person.profile.should be_nil
      @person.save
      Person.all.size.should == 1
      Profile.all.size.should == 0
    end
    
  end
  
  describe "every accessible has(1) association with no reject_if proc", :shared => true do
    
    it "should allow to create a new profile via Person#profile_attributes" do
      @person.profile_attributes = { :nick => 'snusnu' }
      @person.profile.should_not be_nil
      @person.profile.nick.should == 'snusnu'
      @person.save
      @person.profile.should == Profile.first
      Person.all.size.should == 1
      Profile.all.size.should == 1
      Profile.first.nick.should == 'snusnu'
    end
        
    it "should allow to update an existing profile via Person#profile_attributes" do
      @person.save
      profile = Profile.create(:person_id => @person.id, :nick => 'snusnu')
      @person.reload
      
      @person.profile.should == profile
      @person.profile_attributes = { :id => profile.id, :nick => 'still snusnu somehow' }
      @person.profile.nick.should == 'still snusnu somehow'
      @person.save
      @person.profile.should == Profile.first
      Person.all.size.should == 1
      Profile.all.size.should == 1
      Profile.first.nick.should == 'still snusnu somehow'
    end
    
  end
  
  describe "every accessible has(1) association with :allow_destroy => false", :shared => true do
    
    it "should not allow to delete an existing profile via Person#profile_attributes" do
      @person.save
      profile = Profile.create(:person_id => @person.id, :nick => 'snusnu')
      @person.reload
    
      @person.profile_attributes = { :id => profile.id, :_delete => true }
      @person.save
      Person.all.size.should == 1
      Profile.all.size.should == 1
    end
    
  end
  
  describe "every accessible has(1) association with :allow_destroy => true", :shared => true do
    
    it "should allow to delete an existing profile via Person#profile_attributes" do
      @person.save
      profile = Profile.create(:person_id => @person.id, :nick => 'snusnu')
      @person.reload

      @person.profile_attributes = { :id => profile.id, :_delete => true }
      @person.save
      Person.all.size.should == 1
      Profile.all.size.should == 0
    end
    
  end
  
  describe "Person.has(1, :profile)" do
    
    describe "accepts_nested_attributes_for(:profile)" do
    
      before(:each) do
        DataMapper.auto_migrate!
        Person.accepts_nested_attributes_for :profile
        @person = Person.new :name => 'Martin'
      end
    
      it_should_behave_like "every accessible has(1) association with no reject_if proc"
      it_should_behave_like "every accessible has(1) association with :allow_destroy => false"
      
    end
        
    describe "accepts_nested_attributes_for(:profile, :allow_destroy => false)" do
    
      before(:each) do
        DataMapper.auto_migrate!
        Person.accepts_nested_attributes_for :profile, :allow_destroy => false
        @person = Person.new :name => 'Martin'
      end
    
      it_should_behave_like "every accessible has(1) association with no reject_if proc"
      it_should_behave_like "every accessible has(1) association with :allow_destroy => false"
      
    end
    
    describe "accepts_nested_attributes_for(:profile, :allow_destroy => true)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Person.accepts_nested_attributes_for :profile, :allow_destroy => true
        @person = Person.new :name => 'Martin'
      end

      it_should_behave_like "every accessible has(1) association with no reject_if proc"
      it_should_behave_like "every accessible has(1) association with :allow_destroy => true"
      
    end
    
    
    describe "accepts_nested_attributes_for :profile, " do
      
      describe ":reject_if => :foo" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Person.accepts_nested_attributes_for :profile, :reject_if => :foo
          @person = Person.new :name => 'Martin'
        end
    
        it_should_behave_like "every accessible has(1) association with no reject_if proc"
        it_should_behave_like "every accessible has(1) association with :allow_destroy => false"
      
      end
            
      describe ":reject_if => lambda { |attrs| true }" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Person.accepts_nested_attributes_for :profile, :reject_if => lambda { |attrs| true }
          @person = Person.new :name => 'Martin'
        end
    
        it_should_behave_like "every accessible has(1) association with a valid reject_if proc"
        it_should_behave_like "every accessible has(1) association with :allow_destroy => false"
      
      end
                  
      describe ":reject_if => lambda { |attrs| false }" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Person.accepts_nested_attributes_for :profile, :reject_if => lambda { |attrs| false }
          @person = Person.new :name => 'Martin'
        end
    
        it_should_behave_like "every accessible has(1) association with no reject_if proc"
        it_should_behave_like "every accessible has(1) association with :allow_destroy => false"
      
      end
    
    end
    
  
  end
  
end