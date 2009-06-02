describe "every accessible has(n) association with a valid reject_if proc", :shared => true do
  
  it "should not allow to create a new task via Project#tasks_attributes" do
    @project.save
    Project.all.size.should == 1
    Task.all.size.should    == 0
    
    @project.tasks_attributes = { 'new_1' => { :name => 'write specs' } }
    @project.save.should be_true
    
    Project.all.size.should == 1
    Task.all.size.should    == 0
  end
  
end

describe "every accessible has(n) association with no reject_if proc", :shared => true do
  
  it "should allow to create a new task via Project#tasks_attributes" do
    @project.save
    Project.all.size.should == 1
    Task.all.size.should    == 0
    
    @project.tasks_attributes = { 'new_1' => { :name => 'write specs' } }
    @project.save.should be_true
    
    Project.all.size.should == 1
    Task.all.size.should    == 1
    Task.first.name.should  == 'write specs'
  end
      
  it "should allow to update an existing task via Project#tasks_attributes" do
    @project.save
    task = Task.create(:project => @project, :name => 'write specs')
    Project.all.size.should == 1
    Task.all.size.should    == 1
    
    @project.tasks_attributes = { task.id.to_s => { :id => task.id, :name => 'write more specs' } }
    @project.save.should be_true
    
    Project.all.size.should == 1
    Task.all.size.should    == 1
    Task.first.name.should  == 'write more specs'
  end
  
  it "should perform atomic commits" do
    Project.all.size.should == 0
    Task.all.size.should    == 0
    
    # self is invalid
    @project.name = nil # will fail because of validations
    @project.tasks_attributes = { 'new_1' => { :name => 'write specs' } }
    @project.save
    
    Project.all.size.should == 0
    Task.all.size.should    == 0
    
    # related resource is invalid
    @project.name = 'dm-accepts_nested_attributes'
    @project.tasks_attributes = { 'new_1' => { :name => nil } } # will fail because of validations
    @project.save
    
    Project.all.size.should == 0
    Task.all.size.should    == 0
  end
  
end

describe "every accessible has(n) association with :allow_destroy => false", :shared => true do
  
  it "should not allow to delete an existing task via Profile#tasks_attributes" do
    @project.save
    task = Task.create(:project => @project, :name => 'write specs')
    
    Project.all.size.should == 1
    Task.all.size.should    == 1
  
    @project.tasks_attributes = { '1' => { :id => task.id, :_delete => true } }
    @project.save
    
    Project.all.size.should == 1
    Task.all.size.should    == 1
  end
  
end

describe "every accessible has(n) association with :allow_destroy => true", :shared => true do
  
  it "should allow to delete an existing task via Profile#tasks_attributes" do
    @project.save
    task = Task.create(:project => @project, :name => 'write specs')
    
    Project.all.size.should == 1
    Task.all.size.should    == 1
  
    @project.reload
    @project.tasks_attributes = { '1' => { :id => task.id, :_delete => true } }
    @project.save
    
    Project.all.size.should == 1
    Task.all.size.should    == 0
  end
  
end

describe "every accessible has(n) association with a nested attributes reader", :shared => true do

  it "should return the attributes written to Project#task_attributes from the Project#task_attributes reader" do
    @project.tasks_attributes.should be_nil
    @project.tasks_attributes = { 'new_1' => { :name => 'write specs' } }
    @project.tasks_attributes.should == { 'new_1' => { :name => 'write specs' } }
  end

end