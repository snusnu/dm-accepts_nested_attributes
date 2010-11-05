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

  it "should allow to update an existing person, membership and project at the same time" do
    person = Person.create(:id => 1, :name => 'snusnu')
    project = Project.create(:id => 10, :name => 'dm-accepts_nested_attributes')
    membership = Membership.create(:person => person, :project => project, :role => 'maintainer')

    params = {
      :name => 'Martin',
      :memberships_attributes => [{
        :project_id => project.id,
        :role => 'still maintainer',
        :project_attributes => { :name => 'tripping' }
      }]
    }

    # Quick ordered hash hack: make sure the name attribute is updated first,
    # making the person dirty.
    class << params
      def each
        [:name, :memberships_attributes].each { |key| yield key, self[key] }
      end
    end

    person.update params

    Person.all.size.should == 1
    Project.all.size.should == 1
    Membership.all.size.should == 1

    Person.first.attributes.should == { :id => 1, :name => 'Martin' }
    Project.first.attributes.should == { :id => 10, :name => 'tripping' }
    Membership.first.attributes.should == { :person_id => 1, :project_id => 10, :role => 'still maintainer' }
  end

  it "should not allow to update a dirty parent resource with nested attributes" do
    person = Person.create(:id => 1, :name => 'snusnu')
    project = Project.create(:id => 10, :name => 'dm-accepts_nested_attributes')
    membership = Membership.create(:person => person, :project => project, :role => 'maintainer')

    params = {
      :name => 'Martin',
      :memberships_attributes => [{
        :project_id => project.id,
        :role => 'still maintainer',
        :person_attributes => { :name => 'Martin Gamsjaeger' }
      }]
    }
    class <<params
      def each
        [:name, :memberships_attributes].each { |key| yield key, self[key] }
      end
    end
    lambda { person.update(params) }.should raise_error(DataMapper::UpdateConflictError)

    Person.all.size.should == 1
    Project.all.size.should == 1
    Membership.all.size.should == 1

    Person.first.attributes.should == { :id => 1, :name => 'snusnu' }
    Project.first.attributes.should == { :id => 10, :name => 'dm-accepts_nested_attributes' }
    Membership.first.attributes.should == { :person_id => 1, :project_id => 10, :role => 'maintainer' }
  end
end
