require 'spec_helper'

describe "Person.has(1, :profile) with CPK;" do

  before(:all) do

    class ::Person

      include DataMapper::Resource
      extend ConstraintSupport

      property :id,       Serial,  :key => true
      property :audit_id, Integer, :key => true, :min => 0
      property :name,     String,  :required => true

      has 1, :profile, constraint(:destroy)
      has 1, :address, :through => :profile

    end

    class ::Profile

      include DataMapper::Resource

      property :person_id,       Integer, :key => true, :min => 0
      property :person_audit_id, Integer, :key => true, :min => 0
      property :nick,            String,  :required => true

      belongs_to :person
      has 1, :address

    end

    class ::Address

      include DataMapper::Resource

      property :id,               Serial
      property :audit_id,         Integer, :key => true, :min => 0
      property :profile_id,       Integer, :required => true, :unique => :profile, :unique_index => true, :min => 0
      property :profile_audit_id, Integer, :required => true, :unique => :profile, :unique_index => true, :min => 0
      property :body,             String,  :required => true

      belongs_to :profile

    end

    DataMapper.auto_migrate!

  end

  before(:each) do
    Address.all.destroy!
    Profile.all.destroy!
    Person.all.destroy!
  end


  describe "Person.accepts_nested_attributes_for(:profile)" do

    before(:all) do
      Person.accepts_nested_attributes_for :profile
    end

    it_should_behave_like "every accessible one_to_one composite association"
    it_should_behave_like "every accessible one_to_one composite association with no reject_if proc"
    it_should_behave_like "every accessible one_to_one composite association with :allow_destroy => false"

  end

  describe "Person.accepts_nested_attributes_for(:profile, :allow_destroy => false)" do

    before(:all) do
      Person.accepts_nested_attributes_for :profile, :allow_destroy => false
    end

    it_should_behave_like "every accessible one_to_one composite association"
    it_should_behave_like "every accessible one_to_one composite association with no reject_if proc"
    it_should_behave_like "every accessible one_to_one composite association with :allow_destroy => false"

  end

  describe "Person.accepts_nested_attributes_for(:profile, :allow_destroy => true)" do

    before(:all) do
      Person.accepts_nested_attributes_for :profile, :allow_destroy => true
    end

    it_should_behave_like "every accessible one_to_one composite association"
    it_should_behave_like "every accessible one_to_one composite association with no reject_if proc"
    it_should_behave_like "every accessible one_to_one composite association with :allow_destroy => true"

  end

  describe "Person.accepts_nested_attributes_for(:profile, :reject_if => lambda { |attrs| true })" do

    before(:all) do
      Person.accepts_nested_attributes_for :profile, :reject_if => lambda { |attrs| true }
    end

    it_should_behave_like "every accessible one_to_one composite association"
    it_should_behave_like "every accessible one_to_one composite association with a valid reject_if proc"
    it_should_behave_like "every accessible one_to_one composite association with :allow_destroy => false"

  end

  describe "Person.accepts_nested_attributes_for(:profile, :reject_if => lambda { |attrs| false })" do

    before(:all) do
      Person.accepts_nested_attributes_for :profile, :reject_if => lambda { |attrs| false }
    end

    it_should_behave_like "every accessible one_to_one composite association"
    it_should_behave_like "every accessible one_to_one composite association with no reject_if proc"
    it_should_behave_like "every accessible one_to_one composite association with :allow_destroy => false"

  end

  describe "Profile.accepts_nested_attributes_for(:person)" do

    before(:all) do
      Profile.accepts_nested_attributes_for :person
    end

  it "should allow to update an existing profile via Person#profile_attributes" do
    person = Person.create(:audit_id => 1, :name => 'Martin')
    profile = Profile.create(:person => person, :nick => 'snusnu')
    person.reload

    Person.all.size.should    == 1
    Profile.all.size.should   == 1

    profile.person_attributes = { :id => person.id, :audit_id => 1, :name => 'Martin Gamsjaeger' }
    profile.save.should be_true

    Person.all.size.should    == 1
    Profile.all.size.should   == 1
    Person.first.name.should == 'Martin Gamsjaeger'
  end

  it "should return the attributes written to Person#profile_attributes from the Person#profile_attributes reader" do
    profile = Profile.new :nick => 'snusnu'
    profile.person_attributes.should be_nil
    profile.person_attributes = { :name => 'Martin' }
    profile.person_attributes.should == { :name => 'Martin' }
  end

  end

end
