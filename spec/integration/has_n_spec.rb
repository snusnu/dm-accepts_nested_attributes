require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::NestedAttributes do
  
  describe "every accessible has(n) association with a valid reject_if proc", :shared => true do
    
    it "should not allow to create a new task via Project#tasks_attributes" do
      @project.save
      Project.all.size.should == 1
      Task.all.size.should == 0
      
      @project.tasks_attributes = { 'new_1' => { :name => 'write specs' } }
      @project.tasks.should be_empty
      @project.save
      Project.all.size.should == 1
      Task.all.size.should == 0
    end
    
  end
  
  describe "every accessible has(n) association with no reject_if proc", :shared => true do
    
    it "should allow to create a new task via Project#tasks_attributes" do
      @project.save
      Project.all.size.should == 1
      Task.all.size.should == 0
      
      @project.tasks_attributes = { 'new_1' => { :name => 'write specs' } }
      @project.tasks.should_not be_empty
      @project.tasks.first.name.should == 'write specs'
      @project.save
      @project.tasks.first.should == Task.first
      Project.all.size.should == 1
      Task.all.size.should == 1
      Task.first.name.should == 'write specs'
    end
        
    it "should allow to update an existing task via Project#tasks_attributes" do
      @project.save
      task = Task.create(:project => @project, :name => 'write specs')
      Project.all.size.should == 1
      Task.all.size.should == 1
      
      @project.tasks_attributes = { task.id.to_s => { :id => task.id, :name => 'write more specs' } }
      @project.tasks.should_not be_empty
      @project.tasks.first.name.should == 'write more specs'
      @project.save
      
      Project.all.size.should == 1
      Task.all.size.should == 1
      Task.first.name.should == 'write more specs'
    end
    
    it "should perform atomic commits" do
      Project.all.size.should == 0
      Task.all.size.should == 0
      
      @project.name = nil # will fail because of validations
      @project.tasks_attributes = { 'new_1' => { :name => 'write specs' } }
      @project.tasks.should_not be_empty
      @project.tasks.first.name.should == 'write specs'
      @project.save
      @project.should be_new_record
      @project.tasks.all? { |t| t.should be_new_record }
      Project.all.size.should == 0
      Task.all.size.should == 0
      
      # TODO write specs for xxx_attributes= method that test
      # if same hash keys properly get overwritten and not end up being multiple records
      # (which obviously is the case right now)
      
      @project.name = 'dm-accepts_nested_attributes'
      @project.tasks_attributes = { 'new_1' => { :name => nil } } # will fail because of validations
      @project.tasks.should_not be_empty
      @project.tasks.first.name.should be_nil
      @project.save
      @project.should be_new_record
      @project.tasks.all? { |t| t.should be_new_record }
      Project.all.size.should == 0
      Task.all.size.should == 0
    end
    
  end
  
  describe "every accessible has(n) association with :allow_destroy => false", :shared => true do
    
    it "should not allow to delete an existing task via Profile#tasks_attributes" do
      @project.save
      task = Task.create(:project => @project, :name => 'write specs')
      
      Project.all.size.should == 1
      Task.all.size.should    == 1
    
      @project.reload
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
  
  describe "Project.has(n, :tasks)" do
  
    describe "accepts_nested_attributes_for(:tasks)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Project.accepts_nested_attributes_for :tasks
        @project = Project.new :name => 'trippings'
      end
      
      it_should_behave_like "every accessible has(n) association with no reject_if proc"
      it_should_behave_like "every accessible has(n) association with :allow_destroy => false"
      it_should_behave_like "every accessible has(n) association with a nested attributes reader"
      
    end
      
    describe "accepts_nested_attributes_for(:tasks, :allow_destroy => false)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Project.accepts_nested_attributes_for :tasks, :allow_destroy => false
        @project = Project.new :name => 'trippings'
      end
      
      it_should_behave_like "every accessible has(n) association with no reject_if proc"
      it_should_behave_like "every accessible has(n) association with :allow_destroy => false"
      
    end
        
    describe "accepts_nested_attributes_for(:tasks, :allow_destroy => true)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Project.accepts_nested_attributes_for :tasks, :allow_destroy => true
        @project = Project.new :name => 'trippings'
      end
      
      it_should_behave_like "every accessible has(n) association with no reject_if proc"
      it_should_behave_like "every accessible has(n) association with :allow_destroy => true"
      
    end
    
    describe "accepts_nested_attributes_for :tasks, " do
      
      describe ":reject_if => :foo" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Project.accepts_nested_attributes_for :tasks, :reject_if => :foo
          @project = Project.new :name => 'trippings'
        end
    
        it_should_behave_like "every accessible has(n) association with no reject_if proc"
        it_should_behave_like "every accessible has(n) association with :allow_destroy => false"
      
      end
            
      describe ":reject_if => lambda { |attrs| true }" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Project.accepts_nested_attributes_for :tasks, :reject_if => lambda { |attrs| true }
          @project = Project.new :name => 'trippings'
        end
    
        it_should_behave_like "every accessible has(n) association with a valid reject_if proc"
        it_should_behave_like "every accessible has(n) association with :allow_destroy => false"
      
      end
                  
      describe ":reject_if => lambda { |attrs| false }" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Project.accepts_nested_attributes_for :tasks, :reject_if => lambda { |attrs| false }
          @project = Project.new :name => 'trippings'
        end
    
        it_should_behave_like "every accessible has(n) association with no reject_if proc"
        it_should_behave_like "every accessible has(n) association with :allow_destroy => false"
      
      end
    
    end
    
  end
  
end
