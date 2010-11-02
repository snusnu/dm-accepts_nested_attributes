require 'spec_helper'

describe "ProjectMembership.belongs_to(:person) with CPK;" do

  before(:all) do
    class ::Person

      include DataMapper::Resource
      extend ConstraintSupport

      property :id,       Serial,  :key => true
      property :audit_id, Integer, :key => true, :min => 0
      property :name,     String,  :required => true

      has n, :memberships, constraint(:destroy)
      has n, :projects, :through => :memberships

    end

    class ::Project

      include DataMapper::Resource
      extend ConstraintSupport

      property :id,       Serial,  :key => true
      property :audit_id, Integer, :key => true, :min => 0
      property :name,     String,  :required => true

      has n, :memberships, constraint(:destroy)
      has n, :people, :through => :memberships

    end

    class ::Membership

      include DataMapper::Resource

      property :person_id,        Integer, :key => true, :min => 0
      property :person_audit_id,  Integer, :key => true, :min => 0
      property :project_id,       Integer, :key => true, :min => 0
      property :project_audit_id, Integer, :key => true, :min => 0
      property :role,             String,  :required => false

      belongs_to :person, :key => true
      belongs_to :project, :key => true

    end

    DataMapper.auto_migrate!

  end

  before(:each) do
    Membership.all.destroy!
    Project.all.destroy!
    Person.all.destroy!
  end


  describe "Membership.accepts_nested_attributes_for(:person)" do

    before(:all) do
      Membership.accepts_nested_attributes_for :person
    end

    it_should_behave_like "every accessible many_to_one composite association"
    it_should_behave_like "every accessible many_to_one composite association with no reject_if proc"
    it_should_behave_like "every accessible many_to_one composite association with :allow_destroy => false"

  end

  describe "Membership.accepts_nested_attributes_for(:person, :allow_destroy => false)" do

    before(:all) do
      Membership.accepts_nested_attributes_for :person, :allow_destroy => false
    end

    it_should_behave_like "every accessible many_to_one composite association"
    it_should_behave_like "every accessible many_to_one composite association with no reject_if proc"
    it_should_behave_like "every accessible many_to_one composite association with :allow_destroy => false"

  end

  describe "Membership.accepts_nested_attributes_for(:person, :allow_destroy = true)" do

    before(:all) do
      Membership.accepts_nested_attributes_for :person, :allow_destroy => true
    end

    it_should_behave_like "every accessible many_to_one composite association"
    it_should_behave_like "every accessible many_to_one composite association with no reject_if proc"
    it_should_behave_like "every accessible many_to_one composite association with :allow_destroy => true"

  end

  describe "Membership.accepts_nested_attributes_for(:person, :reject_if => lambda { |attrs| true })" do

    before(:all) do
      Membership.accepts_nested_attributes_for :person, :reject_if => lambda { |attrs| true }
    end

    it_should_behave_like "every accessible many_to_one composite association"
    it_should_behave_like "every accessible many_to_one composite association with a valid reject_if proc"
    it_should_behave_like "every accessible many_to_one composite association with :allow_destroy => false"

  end

  describe "Membership.accepts_nested_attributes_for(:person, :reject_if => lambda { |attrs| false })" do

    before(:all) do
      Membership.accepts_nested_attributes_for :person, :reject_if => lambda { |attrs| false }
    end

    it_should_behave_like "every accessible many_to_one composite association"
    it_should_behave_like "every accessible many_to_one composite association with no reject_if proc"
    it_should_behave_like "every accessible many_to_one composite association with :allow_destroy => false"

  end

end
