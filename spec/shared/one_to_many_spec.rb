describe "every accessible one_to_many association", :shared => true do

  it "should allow to update an existing task via Project#tasks_attributes" do
    project = Project.create :name => 'trippings'
    task = Task.create(:project => project, :name => 'write specs')

    Project.all.size.should == 1
    Task.all.size.should    == 1

    project.tasks_attributes = [{ :id => task.id, :name => 'write more specs' }]
    project.save.should be_true

    Project.all.size.should == 1
    Task.all.size.should    == 1
    Task.first.name.should  == 'write more specs'
  end

  it "should return the attributes written with Project#task_attributes= from the Project#task_attributes reader" do
    project = Project.new :name => 'trippings'
    project.tasks_attributes.should be_nil
    project.tasks_attributes = [{ :name => 'write specs' }]
    project.tasks_attributes.should == [{ :name => 'write specs' }]
  end

end

describe "every accessible one_to_many association with a valid reject_if proc", :shared => true do

  it "should not allow to create a new task via Project#tasks_attributes" do
    project = Project.create :name => 'trippings'

    Project.all.size.should == 1
    Task.all.size.should    == 0

    project.tasks_attributes = [{ :name => 'write specs' }]
    project.save.should be_true

    Project.all.size.should == 1
    Task.all.size.should    == 0
  end

end

describe "every accessible one_to_many association with no reject_if proc", :shared => true do

  it "should allow to create a new task via Project#tasks_attributes" do
    project = Project.create :name => 'trippings'

    Project.all.size.should == 1
    Task.all.size.should    == 0

    project.tasks_attributes = [{ :name => 'write specs' }]

    Project.all.size.should == 1
    Task.all.size.should    == 0

    project.save.should be_true

    Project.all.size.should == 1
    Task.all.size.should    == 1
    Task.first.name.should  == 'write specs'
  end

end

describe "every accessible one_to_many association with :allow_destroy => false", :shared => true do

  it "should not allow to delete an existing task via Profile#tasks_attributes" do
    project = Project.create :name => 'trippings'

    task = Task.create(:project => project, :name => 'write specs')

    Project.all.size.should == 1
    Task.all.size.should    == 1

    project.tasks_attributes = [{ :id => task.id, :_delete => true }]
    project.save

    Project.all.size.should == 1
    Task.all.size.should    == 1
  end

end

describe "every accessible one_to_many association with :allow_destroy => true", :shared => true do

  it "should allow to delete an existing task via Profile#tasks_attributes" do
    project = Project.create :name => 'trippings'

    task = Task.create(:project => project, :name => 'write specs')
    project.tasks.reload

    Project.all.size.should == 1
    Task.all.size.should    == 1

    project.tasks_attributes = [{ :id => task.id, :_delete => true }]

    Project.all.size.should == 1
    Task.all.size.should    == 1

    project.save

    Project.all.size.should == 1
    Task.all.size.should    == 0
  end

end
