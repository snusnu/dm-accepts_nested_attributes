describe "every accessible many_to_one composite association", :shared => true do

  it "should allow to update an existing person via Membership#person_attributes" do
    Person.all.size.should     == 0
    Project.all.size.should    == 0
    Membership.all.size.should == 0

    person = Person.create(:audit_id => 1, :name => 'Martin')
    project = Project.create(:audit_id => 2, :name => 'trippings')
    membership = Membership.new(:role => 'maintainer')
    membership.person = person
    membership.project = project
    membership.save.should be_true

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1
    Person.first.name.should   == 'Martin'

    membership.person_attributes = { :id => person.id, :audit_id => person.audit_id, :name => 'Martin Gamsjaeger' }
    membership.save.should be_true

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1
    Person.first.name.should   == 'Martin Gamsjaeger'
  end

  it "should return the attributes written to Membership#person_attributes from the Membership#person_attributes reader" do
    membership = Membership.new(:role => 'maintainer')
    membership.person_attributes.should be_nil
    membership.person_attributes = { :name => 'Martin' }
    membership.person_attributes.should == { :name => 'Martin' }
  end

end

describe "every accessible many_to_one composite association with a valid reject_if proc", :shared => true do

  it "should not allow to create a new person via Membership#person_attributes" do
    project = Project.create(:audit_id => 2, :name => 'trippings')

    Person.all.size.should     == 0
    Project.all.size.should    == 1
    Membership.all.size.should == 0

    membership = Membership.new(:project_id => project.id, :project_audit_id => project.audit_id, :role => 'maintainer')
    membership.person_attributes = { :name => 'Martin' }

    Person.all.size.should     == 0
    Project.all.size.should    == 1
    Membership.all.size.should == 0

    begin
      membership.save.should be(false)
    rescue
      # swallow native FK errors which is basically like expecting save to be false
    end
  end

end

describe "every accessible many_to_one composite association with no reject_if proc", :shared => true do

  it "should allow to create a new person via Membership#person_attributes" do
    project = Project.create(:audit_id => 2, :name => 'trippings')

    Person.all.size.should     == 0
    Project.all.size.should    == 1
    Membership.all.size.should == 0

    membership = Membership.new(:project_id => project.id, :project_audit_id => project.audit_id, :role => 'maintainer')
    membership.person_attributes = { :audit_id => 1, :name => 'Martin' }

    Person.all.size.should     == 0
    Project.all.size.should    == 1
    Membership.all.size.should == 0

    membership.save.should be_true

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1
    Person.first.name.should   == 'Martin'
  end

end

describe "every accessible many_to_one composite association with :allow_destroy => false", :shared => true do

  it "should not allow to delete an existing person via Membership#person_attributes" do
    person = Person.create(:audit_id => 1, :name => 'Martin')
    project = Project.create(:audit_id => 2, :name => 'trippings')
    membership = Membership.new(:role => 'maintainer')
    membership.person = person
    membership.project = project
    membership.save

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    membership.person_attributes = {
      :id => person.id,
      :audit_id => person.audit_id,
      :_delete => true
    }

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    membership.save

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1
  end

end

describe "every accessible many_to_one composite association with :allow_destroy => true", :shared => true do

  it "should allow to delete an existing person via Membership#person_attributes" do
    Person.all.size.should     == 0
    Project.all.size.should    == 0
    Membership.all.size.should == 0

    person = Person.create(:audit_id => 1, :name => 'Martin')
    project = Project.create(:audit_id => 2, :name => 'trippings')

    membership = Membership.new(:role => 'maintainer')
    membership.person = person
    membership.project = project
    membership.save.should be_true

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    membership.person_attributes = {
      :id => person.id,
      :audit_id => person.audit_id,
      :_delete => true
    }

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    membership.save

    Person.all.size.should     == 0
    Project.all.size.should    == 1

    # TODO also test this behavior in situations where setting the FK to nil is allowed

  end

end
