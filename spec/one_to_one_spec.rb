require 'spec_helper'

describe "Person.has(1, :profile);" do

  before(:all) do

    class Person

      include DataMapper::Resource
      extend ConstraintSupport

      property :id,   Serial
      property :name, String, :required => true

      has 1, :profile, constraint(:destroy)
      has 1, :address, :through => :profile

    end

    class Profile

      include DataMapper::Resource

      property :id,        Serial
      property :nick,      String,  :required => true

      belongs_to :person
      has 1, :address

    end

    class Address

      include DataMapper::Resource

      property :id,         Serial
      property :profile_id, Integer, :required => true, :unique => true, :unique_index => true, :min => 0
      property :body,       String,  :required => true

      belongs_to :profile

    end

    DataMapper.auto_upgrade!

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

    it_should_behave_like "every accessible one_to_one association"
    it_should_behave_like "every accessible one_to_one association with no reject_if proc"
    it_should_behave_like "every accessible one_to_one association with :allow_destroy => false"

  end

  describe "Person.accepts_nested_attributes_for(:profile, :allow_destroy => false)" do

    before(:all) do
      Person.accepts_nested_attributes_for :profile, :allow_destroy => false
    end

    it_should_behave_like "every accessible one_to_one association"
    it_should_behave_like "every accessible one_to_one association with no reject_if proc"
    it_should_behave_like "every accessible one_to_one association with :allow_destroy => false"

  end

  describe "Person.accepts_nested_attributes_for(:profile, :allow_destroy => true)" do

    before(:all) do
      Person.accepts_nested_attributes_for :profile, :allow_destroy => true
    end

    it_should_behave_like "every accessible one_to_one association"
    it_should_behave_like "every accessible one_to_one association with no reject_if proc"
    it_should_behave_like "every accessible one_to_one association with :allow_destroy => true"

  end

  describe "Person.accepts_nested_attributes_for(:profile, :reject_if => lambda { |attrs| true })" do

    before(:all) do
      Person.accepts_nested_attributes_for :profile, :reject_if => lambda { |attrs| true }
    end

    it_should_behave_like "every accessible one_to_one association"
    it_should_behave_like "every accessible one_to_one association with a valid reject_if proc"
    it_should_behave_like "every accessible one_to_one association with :allow_destroy => false"

  end

  describe "Person.accepts_nested_attributes_for(:profile, :reject_if => lambda { |attrs| false })" do

    before(:all) do
      Person.accepts_nested_attributes_for :profile, :reject_if => lambda { |attrs| false }
    end

    it_should_behave_like "every accessible one_to_one association"
    it_should_behave_like "every accessible one_to_one association with no reject_if proc"
    it_should_behave_like "every accessible one_to_one association with :allow_destroy => false"

  end

end
