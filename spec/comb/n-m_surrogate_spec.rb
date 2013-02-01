require 'spec_helper'

describe "N:M (surrogate PK)" do
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

      # keep properties unordered
      property :person_audit_id,  Integer, :required => true, :min => 0
      property :project_audit_id, Integer, :required => true, :min => 0
      property :id,               Serial,  :key => true
      property :project_id,       Integer, :required => true, :min => 0
      property :person_id,        Integer, :required => true, :min => 0
      property :role,             String

      belongs_to :person
      belongs_to :project
    end

    DataMapper.auto_migrate!
  end

  before(:each) do
    Membership.all.destroy!
    Project.all.destroy!
    Person.all.destroy!
  end

  describe "Person.accepts_nested_attributes_for(:projects)" do
    before(:all) do
      Person.accepts_nested_attributes_for :projects
    end

    it "should allow to update an existing project via Person#projects_attributes" do
      pending_if "#{DataMapper::Spec.adapter_name} doesn't support M2M", !HAS_M2M_SUPPORT do
        person1  = Person.create(:id => 1, :audit_id => 10, :name => 'Martin')
        project1 = Project.create(:id => 100, :audit_id => 1000, :name => 'foo')
        project2 = Project.create(:id => 200, :audit_id => 2000, :name => 'bar')
        Membership.create(:id => 10000, :person => person1, :project => project1, :role => 'foo-maintainer')
        Membership.create(:id => 20000, :person => person1, :project => project2, :role => 'bar-contributor')
        person1.reload

        person2  = Person.create(:id => 2, :audit_id => 20, :name => 'John')
        project3 = Project.create(:id => 300, :audit_id => 3000, :name => 'qux')
        project4 = Project.create(:id => 400, :audit_id => 4000, :name => 'baz')
        Membership.create(:id => 30000, :person => person2, :project => project3, :role => 'qux-maintainer')
        Membership.create(:id => 40000, :person => person2, :project => project4, :role => 'baz-contributor')
        person2.reload

        Person.all.size.should     == 2
        Project.all.size.should    == 4
        Membership.all.size.should == 4

        person1.projects_attributes = [{ :id => 100, :audit_id => 1000, :name => 'still foo' }]
        person1.save.should be_true

        Person.all.map { |p| [p.id, p.audit_id, p.name] }.should == [
          [1, 10, 'Martin'],
          [2, 20, 'John'],
        ]
        Project.all.map { |p| [p.id, p.audit_id, p.name] }.should == [
          [100, 1000, 'still foo'],
          [200, 2000, 'bar'],
          [300, 3000, 'qux'],
          [400, 4000, 'baz'],
        ]
        Membership.all.map { |m| [m.person_id, m.person_audit_id, m.project_id, m.project_audit_id, m.role] }.should == [
          [1, 10, 100, 1000, 'foo-maintainer'],
          [1, 10, 200, 2000, 'bar-contributor'],
          [2, 20, 300, 3000, 'qux-maintainer'],
          [2, 20, 400, 4000, 'baz-contributor'],
        ]
      end
    end

    it "should allow to create a new project via Person#projects_attributes" do
        person1  = Person.create(:id => 1, :audit_id => 10, :name => 'Martin')
        project1 = Project.create(:id => 100, :audit_id => 1000, :name => 'foo')
        project2 = Project.create(:id => 200, :audit_id => 2000, :name => 'bar')
        Membership.create(:id => 10000, :person => person1, :project => project1, :role => 'foo-maintainer')
        Membership.create(:id => 20000, :person => person1, :project => project2, :role => 'bar-contributor')
        person1.reload

        person2  = Person.create(:id => 2, :audit_id => 20, :name => 'John')
        project3 = Project.create(:id => 300, :audit_id => 3000, :name => 'qux')
        project4 = Project.create(:id => 400, :audit_id => 4000, :name => 'baz')
        Membership.create(:id => 30000, :person => person2, :project => project3, :role => 'qux-maintainer')
        Membership.create(:id => 40000, :person => person2, :project => project4, :role => 'baz-contributor')
        person2.reload

        Person.all.size.should     == 2
        Project.all.size.should    == 4
        Membership.all.size.should == 4

        person1.projects_attributes = [{ :id => 500, :audit_id => 5000, :name => 'fibble' }]
        person1.save.should be_true

        Person.all.map { |p| [p.id, p.audit_id, p.name] }.should == [
          [1, 10, 'Martin'],
          [2, 20, 'John'],
        ]
        Project.all.map { |p| [p.id, p.audit_id, p.name] }.should == [
          [100, 1000, 'foo'],
          [200, 2000, 'bar'],
          [300, 3000, 'qux'],
          [400, 4000, 'baz'],
          [500, 5000, 'fibble'],
        ]

        ids = [10000, 20000, 30000, 40000]
        Membership.all(:id => ids).map { |m|
          [m.id, m.person_id, m.person_audit_id, m.project_id, m.project_audit_id, m.role]
        }.should == [
          [10000, 1, 10, 100, 1000, 'foo-maintainer'],
          [20000, 1, 10, 200, 2000, 'bar-contributor'],
          [30000, 2, 20, 300, 3000, 'qux-maintainer'],
          [40000, 2, 20, 400, 4000, 'baz-contributor'],
        ]

        # exclude the serial property
        Membership.all(:id.not => ids).map { |m|
          [m.person_id, m.person_audit_id, m.project_id, m.project_audit_id, m.role]
        }.should == [
          [1, 10, 500, 5000, nil],
        ]
    end
  end
end
