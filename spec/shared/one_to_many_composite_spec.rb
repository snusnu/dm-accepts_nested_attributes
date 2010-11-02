describe "every accessible one_to_many composite association", :shared => true do

  it "should allow to update an existing membership via Person#memberships_attributes" do
    Person.all.size.should     == 0
    Project.all.size.should    == 0
    Membership.all.size.should == 0

    person = Person.create(:audit_id => 1, :name => 'snusnu')
    project = Project.create(:audit_id => 2, :name => 'dm-accepts_nested_attributes')
    membership = Membership.create(:person => person, :project => project, :role => 'maintainer')

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    person.memberships_attributes = [{ :project_id => project.id, :project_audit_id => project.audit_id, :role => 'still maintainer' }]
    person.save

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    Membership.first.role.should == 'still maintainer'
  end

  it "should return the attributes written with Person#memberships_attributes= from the Person#memberships_attributes reader" do
    person = Person.create(:audit_id => 1, :name => 'snusnu')
    person.memberships_attributes.should be_nil
    person.memberships_attributes = [{ :role => 'maintainer' }]
    person.memberships_attributes.should == [{ :role => 'maintainer' }]
  end

end

describe "every accessible one_to_many composite association with a valid reject_if proc", :shared => true do

  it "should not allow to create a new membership via Project#memberships_attributes" do
    person  = Person.create(:audit_id => 1, :name => 'snusnu')
    project = Project.create(:audit_id => 2, :name => 'trippings')

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 0

    person.memberships_attributes = [{
      :project_id => project.id,
      :project_audit_id => project.audit_id,
      :role => 'contributor'
    }]
    project.save.should be_true

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 0
  end

end

describe "every accessible one_to_many composite association with no reject_if proc", :shared => true do

  it "should allow to create a new membership via Person#memberships_attributes" do
    person  = Person.create(:audit_id => 1, :name => 'snusnu')
    project = Project.create(:audit_id => 2, :name => 'trippings')

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 0

    person.memberships_attributes = [{
      :project_id => project.id,
      :project_audit_id => project.audit_id,
      :role => 'contributor'
    }]

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 0

    person.save.should be_true

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    membership = Membership.first
    membership.person.should  == person
    membership.project.should == project
    membership.role.should    == 'contributor'
  end

end

describe "every accessible one_to_many composite association with :allow_destroy => false", :shared => true do

  it "should not allow to delete an existing membership via Person#memberships_attributes" do
    person  = Person.create(:audit_id => 1, :name => 'snusnu')
    project = Project.create(:audit_id => 2, :name => 'trippings')

    membership = Membership.create(:person => person, :project => project, :role => 'contributor')

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    person.memberships_attributes = [{
      :project_id => project.id,
      :project_audit_id => project.audit_id,
      :_delete => true
    }]
    person.save

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    Person.first.attributes.should     == { :id => person.id, :audit_id => 1, :name => 'snusnu' }
    Project.first.attributes.should    == { :id => project.id, :audit_id => 2, :name => 'trippings' }
    Membership.first.attributes.should == {
      :person_id => person.id,
      :person_audit_id => person.audit_id,
      :project_id => project.id,
      :project_audit_id => project.audit_id,
      :role => 'contributor'
    }
  end

end

describe "every accessible one_to_many composite association with :allow_destroy => true", :shared => true do

  it "should allow to delete an existing membership via Person#membership_attributes" do
    person  = Person.create(:audit_id => 1, :name => 'snusnu')
    project = Project.create(:audit_id => 2, :name => 'trippings')

    membership = Membership.create(:person => person, :project => project, :role => 'maintainer')
    person.memberships.reload

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    person.memberships_attributes = [{
      :project_id => project.id,
      :project_audit_id => project.audit_id,
      :_delete => true
    }]

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    person.save

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 0
  end

end
