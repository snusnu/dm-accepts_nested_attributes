require 'spec_helper'

describe "1:M (PK subset FK)" do
  before(:all) do
    class ::Person
      include DataMapper::Resource
      extend ConstraintSupport

      property :id,       Serial,  :key => true
      property :audit_id, Integer, :key => true, :min => 0
      property :name,     String,  :required => true

      has n, :memberships, constraint(:destroy)
    end

    class ::Membership
      include DataMapper::Resource

      # keep properties unordered
      property :person_audit_id,  Integer, :key => false, :min => 0
      property :person_id,        Integer, :key => true, :min => 0
      property :role,             String,  :required => true

      belongs_to :person
    end

    DataMapper.auto_migrate!
  end

  before(:each) do
    Membership.all.destroy!
    Person.all.destroy!
  end

  describe "Person.accepts_nested_attributes_for(:memberships)" do
    before(:all) do
      Person.accepts_nested_attributes_for :memberships
    end

    it "should allow to update an existing membership via Person#memberships_attributes" do
      person1  = Person.create(:id => 1, :audit_id => 10, :name => 'Martin')
      Membership.create(:person => person1, :role => 'maintainer')
      person1.reload

      person2  = Person.create(:id => 2, :audit_id => 20, :name => 'John')
      Membership.create(:person => person2, :role => 'contributor')
      person2.reload

      Person.all.size.should     == 2
      Membership.all.size.should == 2

      person1.memberships_attributes = [{ :role => 'tester' }]
      person1.save.should be_true

      Person.all.map { |p| [p.id, p.audit_id, p.name] }.should == [
        [1, 10, 'Martin'],
        [2, 20, 'John'],
      ]
      Membership.all.map { |m| [m.person_id, m.person_audit_id, m.role] }.should == [
        [1, 10, 'tester'],
        [2, 20, 'contributor'],
      ]
    end
  end
end
