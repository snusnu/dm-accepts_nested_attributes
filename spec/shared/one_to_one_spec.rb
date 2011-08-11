describe "every accessible one_to_one association", :shared => true do

  describe "Person#profile_attributes" do
    it "should allow to update an existing profile" do
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
  
    it "should typecast the profile key" do
      person = Person.create :name => 'Martin'
      profile = Profile.create(:person => person, :nick => 'snusnu')
      person.reload

      Person.all.size.should    == 1
      Profile.all.size.should   == 1

      person.profile_attributes = { :id => profile.id.to_s, :nick => 'still snusnu somehow' }
      person.profile.id.should  == profile.id
      person.save.should be_true

      Person.all.size.should    == 1
      Profile.all.size.should   == 1
      Profile.first.nick.should == 'still snusnu somehow'
    end

    it "should return the attributes written from the reader" do
      person = Person.new :name => 'Martin'
      person.profile_attributes.should be_nil
      person.profile_attributes = { :nick => 'snusnu' }
      person.profile_attributes.should == { :nick => 'snusnu' }
    end
  end
  
  describe "with deeply-nested associations" do
    describe "Profile.accepts_nested_attributes_for(:address)" do
      before(:all) do
        Profile.accepts_nested_attributes_for(:address)
      end
      
      it "should allow to update an existing address via Person#profile_attributes" do
        person  = Person.create :name => 'Barak Obama'
        profile = Profile.create(:person => person, :nick => 'Renegade')
        address = Address.create(:profile => profile, :body => '1600 Pennsylvania Ave, Washington DC')
        person.reload
        
        Person.all.size.should    == 1
        Profile.all.size.should   == 1
        Address.all.size.should   == 1

        person.update(:profile_attributes => { :id => profile.id, :address_attributes => { :id => address.id, :body => 'Camp David, Thurmont MA' } })
        person.save.should be_true

        Person.all.size.should    == 1
        Profile.all.size.should   == 1
        Address.all.size.should   == 1
        Address.first.body.should == 'Camp David, Thurmont MA'
      end
    end
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
