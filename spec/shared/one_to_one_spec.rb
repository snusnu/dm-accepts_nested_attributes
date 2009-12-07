describe "every accessible one_to_one association", :shared => true do

  it "should allow to update an existing profile via Person#profile_attributes" do
    person = Person.create :name => 'Martin'
    profile = Profile.create(:person => person, :nick => 'snusnu')
    person.reload

    Person.all.size.should    == 1
    Profile.all.size.should   == 1

    person.profile_attributes = { :id => profile.id, :nick => 'still snusnu somehow' }
    person.save.should be_true

    Person.all.size.should    == 1
    Profile.all.size.should   == 1
    Profile.first.nick.should == 'still snusnu somehow'
  end

  it "should return the attributes written to Person#profile_attributes from the Person#profile_attributes reader" do
    person = Person.new :name => 'Martin'
    person.profile_attributes.should be_nil
    person.profile_attributes = { :nick => 'snusnu' }
    person.profile_attributes.should == { :nick => 'snusnu' }
  end

end

describe "every accessible one_to_one association with a valid reject_if proc", :shared => true do

  it "should not allow to create a new profile via Person#profile_attributes" do
    Person.all.size.should  == 0
    Profile.all.size.should == 0

    person = Person.new :name => 'Martin'
    person.profile_attributes = { :nick => 'snusnu' }
    person.save

    Person.all.size.should  == 1
    Profile.all.size.should == 0
  end

end

describe "every accessible one_to_one association with no reject_if proc", :shared => true do

  it "should allow to create a new profile via Person#profile_attributes" do
    Person.all.size.should    == 0
    Profile.all.size.should   == 0

    person = Person.new :name => 'Martin'
    person.profile_attributes = { :nick => 'snusnu' }

    Person.all.size.should    == 0
    Profile.all.size.should   == 0

    person.save.should be_true

    Person.all.size.should    == 1
    Profile.all.size.should   == 1
    Profile.first.nick.should == 'snusnu'
  end

  it "should perform atomic commits" do

    # related resource is invalid
    person = Person.new :name => 'Martin'
    person.profile_attributes = { :nick => nil } # will fail because of validations
    person.save.should be_false

    Person.all.size.should == 0
    Profile.all.size.should == 0

    # self is invalid
    person.name = nil # will fail because of validations
    person.profile_attributes = { :nick => 'snusnu' }
    person.save.should be_false

    Person.all.size.should  == 0
    Profile.all.size.should == 0
  end

end

describe "every accessible one_to_one association with :allow_destroy => false", :shared => true do

  it "should not allow to delete an existing profile via Person#profile_attributes" do
    person = Person.create :name => 'Martin'

    profile = Profile.create(:person => person, :nick => 'snusnu')
    person.reload

    Person.all.size.should  == 1
    Profile.all.size.should == 1

    person.profile_attributes = { :id => profile.id, :_delete => true }

    Person.all.size.should  == 1
    Profile.all.size.should == 1

    person.save

    Person.all.size.should  == 1
    Profile.all.size.should == 1
  end

end

describe "every accessible one_to_one association with :allow_destroy => true", :shared => true do

  it "should allow to delete an existing profile via Person#profile_attributes" do
    person = Person.create :name => 'Martin'

    profile = Profile.create(:person => person, :nick => 'snusnu')
    person.profile = profile

    Person.all.size.should  == 1
    Profile.all.size.should == 1

    person.profile_attributes = { :id => profile.id, :_delete => true }

    Person.all.size.should  == 1
    Profile.all.size.should == 1

    person.save

    Person.all.size.should  == 1
    Profile.all.size.should == 0
  end

end
