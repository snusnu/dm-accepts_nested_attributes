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
    @person.save.should be_true
    
    Person.all.size.should == 1
    Profile.all.size.should == 1
    Profile.first.nick.should == 'snusnu'
  end
      
  it "should allow to update an existing profile via Person#profile_attributes" do
    @person.save.should be_true
    profile = Profile.create(:person_id => @person.id, :nick => 'snusnu')
    @person.reload
    
    @person.profile.should == profile
    @person.profile_attributes = { :id => profile.id, :nick => 'still snusnu somehow' }
    @person.profile.nick.should == 'still snusnu somehow'
    @person.save.should be_true
    @person.profile.should == Profile.first
    Person.all.size.should == 1
    Profile.all.size.should == 1
    Profile.first.nick.should == 'still snusnu somehow'
  end
  
  it "should perform atomic commits" do
    @person.profile_attributes = { :nick => nil } # will fail because of validations
    @person.profile.should_not be_nil
    @person.profile.nick.should be_nil
    @person.save.should be_false
    
    Person.all.size.should == 0
    Profile.all.size.should == 0
    
    @person.profile_attributes = { :nick => 'snusnu' }
    @person.profile.should_not be_nil
    @person.profile.nick.should == 'snusnu'
    @person.name = nil # will fail because of validations
    @person.save.should be_false
    
    Person.all.size.should == 0
    Profile.all.size.should == 0
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

describe "every accessible has(1) association with a nested attributes reader", :shared => true do

  it "should return the attributes written to Person#profile_attributes from the Person#profile_attributes reader" do
    @person.profile_attributes.should be_nil

    @person.profile_attributes = { :nick => 'snusnu' }

    @person.profile_attributes.should == { :nick => 'snusnu' }
  end

end