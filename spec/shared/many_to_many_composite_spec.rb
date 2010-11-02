describe "every accessible many_to_many composite association", :shared => true do

  it "should allow to update an existing project via Person#projects_attributes" do
    pending_if "#{DataMapper::Spec.adapter_name} doesn't support M2M", !HAS_M2M_SUPPORT do
      Person.all.size.should     == 0
      Project.all.size.should    == 0
      Membership.all.size.should == 0

      person = Person.create(:audit_id => 1, :name => 'snusnu')
      project = Project.create(:audit_id => 2, :name => 'dm-accepts_nested_attributes')
      membership = Membership.create(:person => person, :project => project, :role => 'maintainer')

      Person.all.size.should     == 1
      Project.all.size.should    == 1
      Membership.all.size.should == 1

      person.projects_attributes = [{
        :id => project.id,
        :audit_id => project.audit_id,
        :name => 'still dm-accepts_nested_attributes'
      }]
      person.save

      Person.all.size.should     == 1
      Project.all.size.should    == 1
      Membership.all.size.should == 1

      Project.first.name.should == 'still dm-accepts_nested_attributes'
    end
  end

  it "should return the attributes written to Person#projects_attributes from the Person#projects_attributes reader" do
    person = Person.new(:audit_id => 1, :name => 'snusnu')
    person.projects_attributes.should be_nil
    person.projects_attributes = [{ :name => 'write specs' }]
    person.projects_attributes.should == [{ :name => 'write specs' }]
  end

end

describe "every accessible many_to_many composite association with a valid reject_if proc", :shared => true do

  it "should not allow to create a new project via Person#projects_attributes" do
    Person.all.size.should     == 0
    Project.all.size.should    == 0
    Membership.all.size.should == 0

    person = Person.create(:audit_id => 1, :name => 'snusnu')

    Person.all.size.should     == 1
    Project.all.size.should    == 0
    Membership.all.size.should == 0

    person.projects_attributes = [{ :name => 'dm-accepts_nested_attributes' }]
    person.save

    Person.all.size.should     == 1
    Project.all.size.should    == 0
    Membership.all.size.should == 0
  end

end

describe "every accessible many_to_many composite association with no reject_if proc", :shared => true do

  it "should allow to create a new project via Person#projects_attributes" do
    Person.all.size.should     == 0
    Project.all.size.should    == 0
    Membership.all.size.should == 0

    person = Person.create(:audit_id => 1, :name => 'snusnu')

    Person.all.size.should     == 1
    Project.all.size.should    == 0
    Membership.all.size.should == 0

    person.projects_attributes = [{ :audit_id => 2, :name => 'dm-accepts_nested_attributes' }]

    Person.all.size.should     == 1
    Project.all.size.should    == 0
    Membership.all.size.should == 0

    person.save

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    Project.first.name.should == 'dm-accepts_nested_attributes'
  end

end

describe "every accessible many_to_many composite association with :allow_destroy => false", :shared => true do

  it "should not allow to delete an existing project via Person#projects_attributes" do
    person = Person.create(:audit_id => 1, :name => 'snusnu')
    project = Project.create(:audit_id => 2, :name => 'dm-accepts_nested_attributes')
    membership = Membership.create(:person => person, :project => project)

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    person.projects_attributes = [{ :id => project.id, :audit_id => project.audit_id, :_delete => true }]

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1

    person.save

    Person.all.size.should     == 1
    Project.all.size.should    == 1
    Membership.all.size.should == 1
  end

end

describe "every accessible many_to_many composite association with :allow_destroy => true", :shared => true do

  it "should allow to delete an existing project via Person#projects_attributes" do
    pending_if "#{DataMapper::Spec.adapter_name} doesn't support M2M", !HAS_M2M_SUPPORT do
      person = Person.create(:audit_id => 1, :name => 'snusnu')

      project_1 = Project.create(:audit_id => 2, :name => 'dm-accepts_nested_attributes')
      project_2 = Project.create(:audit_id => 3, :name => 'dm-is-localizable')
      membership_1 = Membership.create(:person => person, :project => project_1)
      membership_2 = Membership.create(:person => person, :project => project_2)

      Person.all.size.should     == 1
      Project.all.size.should    == 2
      Membership.all.size.should == 2

      person.projects_attributes = [{ :id => project_1.id, :audit_id => project_1.audit_id, :_delete => true }]

      Person.all.size.should     == 1
      Project.all.size.should    == 2
      Membership.all.size.should == 2

      person.save

      Person.all.size.should     == 1
      Project.all.size.should    == 1
      Membership.all.size.should == 1
    end
  end

end
