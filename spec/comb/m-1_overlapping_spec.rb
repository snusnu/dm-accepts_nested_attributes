require 'spec_helper'

describe "M:1 (PK overlapping FK)" do
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
      property :rank,            Integer, :key => true
      property :person_audit_id, Integer, :min => 0
      property :person_id,       Integer, :key => true, :min => 0
      property :role,            String,  :required => true

      belongs_to :person
    end

    DataMapper.auto_migrate!
  end

  before(:each) do
    Membership.all.destroy!
    Person.all.destroy!
  end

  describe "Membership.accepts_nested_attributes_for(:person)" do
    before(:all) do
      Membership.accepts_nested_attributes_for :person
    end

    it "should allow to update an existing person via Membership#person_attributes" do
      person1  = Person.create(:id => 1, :audit_id => 10, :name => 'Martin')
      membership = Membership.create(:person => person1, :rank => 100, :role => 'maintainer')
      Membership.create(:person => person1, :rank => 101, :role => 'user')
      person1.reload

      person2  = Person.create(:id => 2, :audit_id => 20, :name => 'John')
      Membership.create(:person => person2, :rank => 200, :role => 'contributor')
      Membership.create(:person => person2, :rank => 201, :role => 'release-manager')
      person2.reload

      Person.all.size.should     == 2
      Membership.all.size.should == 4

      membership.person_attributes = { :name => 'Martin Gamsjaeger' }
      membership.save.should be_true

      Person.all.map { |p| [p.id, p.audit_id, p.name] }.should == [
        [1, 10, 'Martin Gamsjaeger'],
        [2, 20, 'John'],
      ]
      Membership.all.map { |m| [m.person_id, m.person_audit_id, m.rank, m.role] }.should == [
        [1, 10, 100, 'maintainer'],
        [1, 10, 101, 'user'],
        [2, 20, 200, 'contributor'],
        [2, 20, 201, 'release-manager'],
      ]
    end
  end
end
