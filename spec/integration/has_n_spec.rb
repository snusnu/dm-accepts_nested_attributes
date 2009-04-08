require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::NestedAttributes do
  
  describe "every accessible has(n) association", :shared => true do
    
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
    
  end
  
  describe "Project.has(n, :tasks)" do
  
    describe "accepts_nested_attributes_for(:tasks, :allow_destroy = false)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Project.accepts_nested_attributes_for :tasks
        @project = Project.new :name => 'trippings'
      end
      
      it_should_behave_like "every accessible has(n) association"
      
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
        
    describe "accepts_nested_attributes_for(:tasks, :allow_destroy = true)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Project.accepts_nested_attributes_for :tasks, :allow_destroy => true
        @project = Project.new :name => 'trippings'
      end
      
      it_should_behave_like "every accessible has(n) association"
      
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
    
  end
  
end