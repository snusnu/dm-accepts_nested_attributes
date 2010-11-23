require 'spec_helper'

describe DataMapper::NestedAttributes::Resource do

  before(:all) do
    class ::Project
      include DataMapper::Resource
      extend ConstraintSupport
    
      property :id, Integer, :key => true, :min => 0
      property :name, String, :required => true

      has n, :memberships, constraint(:destroy)
      has n, :people, :through => :memberships
    end

    class ::Person
      include DataMapper::Resource
      extend ConstraintSupport

      property :id, Integer, :key => true, :min => 0
      property :name, String, :required => true

      has n, :memberships, constraint(:destroy)
      has n, :projects, :through => :memberships
      accepts_nested_attributes_for :memberships, :allow_destroy => true
    end

    class ::Membership
      include DataMapper::Resource

      property :person_id, Integer, :key => true, :min => 0
      property :project_id, Integer, :key => true, :min => 0
      property :role, String, :required => true

      belongs_to :person
      belongs_to :project

      accepts_nested_attributes_for :person
      accepts_nested_attributes_for :project
    end

    DataMapper.auto_migrate!
  end

  before(:each) do
    Membership.all.destroy!
    Person.all.destroy!
    Project.all.destroy!
  end

  describe "#unassignable_keys" do
    it "includes primary keys and delete marker" do
      Person.new.send(:unassignable_keys).should == [:id, :_delete]
      Membership.new.send(:unassignable_keys).should == [:person_id, :project_id, :_delete]
    end
  end
end
