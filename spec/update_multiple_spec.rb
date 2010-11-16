require 'spec_helper'

describe "Person.has(n, :memberships)" do

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

  it "should add, update and remove memberships together in a single attribute assignment" do
    person = Person.create(:id => 1, :name => 'snusnu')
    project1 = Project.create(:id => 10, :name => 'dm-accepts_nested_attributes')
    project2 = Project.create(:id => 20, :name => 'dm-core')
    project3 = Project.create(:id => 30, :name => 'dm-validations')
    Membership.create(:person => person, :project => project1, :role => 'maintainer')
    Membership.create(:person => person, :project => project2, :role => 'contributor')

    person.memberships_attributes = [
      { :project_id => project1.id, :role => 'still maintainer' }, # update
      { :project_id => project2.id, :_delete => true }, # remove
      { :project_id => project3.id, :role => 'user' }, # add
    ]
    person.save

    Person.all.size.should == 1
    Person.first.attributes.should == { :id => 1, :name => 'snusnu' }
    Project.all(:order => :id).map { |r| r.attributes }.should == [
      { :id => 10, :name => 'dm-accepts_nested_attributes' },
      { :id => 20, :name => 'dm-core' },
      { :id => 30, :name => 'dm-validations' }
    ]
    Membership.all(:order => [:person_id, :project_id]).map { |r| r.attributes }.should == [
      { :person_id => 1, :project_id => 10, :role => 'still maintainer' },
      { :person_id => 1, :project_id => 30, :role => 'user' }
    ]
  end
end
