require 'spec_helper'

describe "Profile.belongs_to(:person);" do

  before(:all) do

    class ::Person

      include DataMapper::Resource
      extend ConstraintSupport

      property :id,   Serial
      property :name, String, :required => true

      has 1, :profile, constraint(:destroy)

    end

    class ::Profile

      include DataMapper::Resource

      property :id,        Serial
      property :person_id, Integer, :required => true, :min => 0
      property :nick,      String,  :required => true

      belongs_to :person

    end

    DataMapper.auto_migrate!

  end

  before(:each) do
    Profile.all.destroy!
    Person.all.destroy!    
  end


  describe "Profile.accepts_nested_attributes_for(:person)" do

    before(:all) do
      Profile.accepts_nested_attributes_for :person
    end

    it_should_behave_like "every accessible many_to_one association"
    it_should_behave_like "every accessible many_to_one association with no reject_if proc"
    it_should_behave_like "every accessible many_to_one association with :allow_destroy => false"

  end

  describe "Profile.accepts_nested_attributes_for(:person, :allow_destroy => false)" do

    before(:all) do
      Profile.accepts_nested_attributes_for :person, :allow_destroy => false
    end

    it_should_behave_like "every accessible many_to_one association"
    it_should_behave_like "every accessible many_to_one association with no reject_if proc"
    it_should_behave_like "every accessible many_to_one association with :allow_destroy => false"

  end

  describe "Profile.accepts_nested_attributes_for(:person, :allow_destroy = true)" do

    before(:all) do
      Profile.accepts_nested_attributes_for :person, :allow_destroy => true
    end

    it_should_behave_like "every accessible many_to_one association"
    it_should_behave_like "every accessible many_to_one association with no reject_if proc"
    it_should_behave_like "every accessible many_to_one association with :allow_destroy => true"

  end

  describe "Profile.accepts_nested_attributes_for(:person, :reject_if => lambda { |attrs| true })" do

    before(:all) do
      Profile.accepts_nested_attributes_for :person, :reject_if => lambda { |attrs| true }
    end

    it_should_behave_like "every accessible many_to_one association"
    it_should_behave_like "every accessible many_to_one association with a valid reject_if proc"
    it_should_behave_like "every accessible many_to_one association with :allow_destroy => false"

  end

  describe "Profile.accepts_nested_attributes_for(:person, :reject_if => lambda { |attrs| false })" do

    before(:all) do
      Profile.accepts_nested_attributes_for :person, :reject_if => lambda { |attrs| false }
    end

    it_should_behave_like "every accessible many_to_one association"
    it_should_behave_like "every accessible many_to_one association with no reject_if proc"
    it_should_behave_like "every accessible many_to_one association with :allow_destroy => false"

  end

end
