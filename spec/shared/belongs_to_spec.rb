describe "every accessible belongs_to association", :shared => true do
  
  it "should allow to update an existing person via Profile#person_attributes" do
    Profile.all.size.should == 0
    Person.all.size.should  == 0
    
    person = Person.create(:name => 'Martin')
    @profile.person = person
    @profile.save.should be_true
  
    Profile.all.size.should  == 1
    Person.all.size.should   == 1
    Person.first.name.should == 'Martin'
  
    @profile.person_attributes = { :id => person.id, :name => 'Martin Gamsjaeger' }
    @profile.save.should be_true
  
    Profile.all.size.should  == 1
    Person.all.size.should   == 1
    Person.first.name.should == 'Martin Gamsjaeger'
  end
  
  it "should perform atomic commits" do
    Profile.all.size.should == 0
    Person.all.size.should  == 0
    
    # related resource is invalid
    @profile.person_attributes = { :name => nil }
    @profile.save.should be_false
    
    Profile.all.size.should == 0
    Person.all.size.should  == 0
  
    # self is invalid
    @profile.nick = nil
    @profile.person_attributes = { :name => 'Martin' }
    @profile.save.should be_false
    
    Profile.all.size.should == 0
    Person.all.size.should == 0
  end

  it "should return the attributes written to Profile#person_attributes from the Profile#person_attributes reader" do
    @profile.person_attributes.should be_nil
    @profile.person_attributes = { :name => 'Martin' }
    @profile.person_attributes.should == { :name => 'Martin' }
  end

end

describe "every accessible belongs_to association with a valid reject_if proc", :shared => true do

  it "should not allow to create a new person via Profile#person_attributes" do
    Profile.all.size.should == 0
    Person.all.size.should  == 0

    @profile.person_attributes = { :name => 'Martin' }
    @profile.save.should be_false

    Profile.all.size.should == 0
    Person.all.size.should  == 0
  end

end

describe "every accessible belongs_to association with no reject_if proc", :shared => true do

  it "should allow to create a new person via Profile#person_attributes" do
    Profile.all.size.should == 0
    Person.all.size.should  == 0

    @profile.person_attributes = { :name => 'Martin' }
    @profile.save.should be_true

    Profile.all.size.should  == 1
    Person.all.size.should   == 1
    Person.first.name.should == 'Martin'
  end

end

describe "every accessible belongs_to association with :allow_destroy => false", :shared => true do
  
  it "should not allow to delete an existing person via Profile#person_attributes" do
    Profile.all.size.should == 0
    Person.all.size.should  == 0
    
    person = Person.create(:name => 'Martin')
    @profile.person = person
    @profile.save.should be_true
    
    Profile.all.size.should == 1
    Person.all.size.should  == 1
  
    @profile.person_attributes = { :id => person.id, :_delete => true }
    @profile.save
    
    Profile.all.size.should == 1
    Person.all.size.should  == 1
  end
  
end
  
describe "every accessible belongs_to association with :allow_destroy => true", :shared => true do
  
  it "should allow to delete an existing person via Profile#person_attributes" do
    Profile.all.size.should == 0
    Person.all.size.should  == 0
    
    person = Person.create(:name => 'Martin')
    @profile.person = person
    @profile.save.should be_true
    
    Profile.all.size.should == 1
    Person.all.size.should  == 1
  
    @profile.person_attributes = { :id => person.id, :_delete => true }
    @profile.save
    
    Person.all.size.should  == 0
    
    # TODO also test this behavior in situations where setting the FK to nil is allowed
    
  end

end
