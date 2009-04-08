require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::NestedAttributes do
  
  describe "every accessible has(n, :through) association", :shared => true do
    
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
    
  end
  
  describe "Person.has(n, :projects, :through => :project_memberships)" do
  
    describe "accepts_nested_attributes_for(:projects, :allow_destroy = false)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Person.accepts_nested_attributes_for :projects
        @person = Person.new :name => 'snusnu'
      end
      
      it_should_behave_like "every accessible has(n, :through) association"
      
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
        
    describe "accepts_nested_attributes_for(:projects, :allow_destroy = true)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Person.accepts_nested_attributes_for :projects, :allow_destroy => true
        @person = Person.new :name => 'snusnu'
      end
      
      it_should_behave_like "every accessible has(n, :through) association"
      
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
    
  end
  
end