describe "every accessible has(n, :through) association with a valid reject_if proc", :shared => true do

  it "should not allow to create a new project via Person#projects_attributes" do
    @person.save
    Person.all.size.should == 1
    ProjectMembership.all.size.should == 0
    Project.all.size.should == 0
    
    @person.projects_attributes = { 'new_1' => { :name => 'dm-accepts_nested_attributes' } }
    @person.projects.should be_empty
    @person.save
    
    Person.all.size.should == 1
    ProjectMembership.all.size.should == 0
    Project.all.size.should == 0
  end
  
end

describe "every accessible has(n, :through) association with no reject_if proc", :shared => true do
  
  it "should allow to create a new project via Person#projects_attributes" do
    @person.save
    Person.all.size.should == 1
    ProjectMembership.all.size.should == 0
    Project.all.size.should == 0
    
    @person.projects_attributes = { 'new_1' => { :name => 'dm-accepts_nested_attributes' } }
    @person.projects.should_not be_empty
    @person.projects.first.name.should == 'dm-accepts_nested_attributes'
    @person.save
    @person.projects.first.should == Project.first
    
    Person.all.size.should == 1
    ProjectMembership.all.size.should == 1
    Project.all.size.should == 1
    
    Project.first.name.should == 'dm-accepts_nested_attributes'
  end
      
  it "should allow to update an existing project via Person#projects_attributes" do
    @person.save
    project = Project.create(:name => 'dm-accepts_nested_attributes')
    project_membership = ProjectMembership.create(:person => @person, :project => project)
    Person.all.size.should == 1
    Project.all.size.should == 1
    ProjectMembership.all.size.should == 1
    
    @person.reload
    
    @person.projects_attributes = { project.id.to_s => { :id => project.id, :name => 'still dm-accepts_nested_attributes' } }
    @person.projects.should_not be_empty
    @person.projects.first.name.should == 'still dm-accepts_nested_attributes'
    @person.save
    
    Person.all.size.should == 1
    ProjectMembership.all.size.should == 1
    Project.all.size.should == 1
    
    Project.first.name.should == 'still dm-accepts_nested_attributes'
  end
  
  it "should perform atomic commits" do
    
    @person.projects_attributes = { 'new_1' => { :name => nil } } # should fail because of validations
    @person.projects.should be_empty
    @person.save
    @person.projects.should be_empty
    
    Person.all.size.should            == 1
    ProjectMembership.all.size.should == 0
    Project.all.size.should           == 0
    
    @person.name = nil # should fail because of validations
    @person.projects_attributes = { 'new_1' => { :name => nil } }
    @person.projects.should be_empty
    @person.save
    @person.projects.should be_empty
    
    Person.all.size.should            == 0
    ProjectMembership.all.size.should == 0
    Project.all.size.should           == 0
    
  end
  
end

describe "every accessible has(n, :through) association with :allow_destroy => false", :shared => true do
  
  it "should not allow to delete an existing project via Person#projects_attributes" do
    @person.save
    project = Project.create(:name => 'dm-accepts_nested_attributes')
    project_membership = ProjectMembership.create(:person => @person, :project => project)
    
    Person.all.size.should            == 1
    ProjectMembership.all.size.should == 1
    Project.all.size.should           == 1
  
    @person.reload
    @person.projects_attributes = { '1' => { :id => project.id, :_delete => true } }
    @person.save
    
    Person.all.size.should            == 1
    ProjectMembership.all.size.should == 1
    Project.all.size.should           == 1
  end
  
end

describe "every accessible has(n, :through) association with :allow_destroy => true", :shared => true do
  
  it "should allow to delete an existing project via Person#projects_attributes" do
    @person.save
    project = Project.create(:name => 'dm-accepts_nested_attributes')
    project_membership = ProjectMembership.create(:person => @person, :project => project)
    
    Person.all.size.should            == 1
    ProjectMembership.all.size.should == 1
    Project.all.size.should           == 1
  
    @person.reload
    @person.projects_attributes = { '1' => { :id => project.id, :_delete => true } }
    @person.save
    
    Person.all.size.should            == 1
    ProjectMembership.all.size.should == 0
    Project.all.size.should           == 0
  end
  
end

describe "every accessible has(n, :through) association with a nested attributes reader", :shared => true do

  it "should return the attributes written to Person#projects_attributes from the Person#projects_attributes reader" do
    @person.projects_attributes.should be_nil

    @person.projects_attributes = { 'new_1' => { :name => 'write specs' } }

    @person.projects_attributes.should == { 'new_1' => { :name => 'write specs' } }
  end

end