require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

# TODO: this is overkill - really should use some more focussed unit tests instead
describe DataMapper::NestedAttributes do
  
  describe "every accessible has(n, :through) renamed association with a valid reject_if proc", :shared => true do
  
    it "should not allow to create a new picture via Tag#pictures_attributes" do
      @tag.save
      Tag.all.size.should     == 1
      Tagging.all.size.should == 0
      Photo.all.size.should   == 0
      
      @tag.pictures_attributes = { 'new_1' => { :name => 'dm-accepts_nested_attributes' } }
      @tag.pictures.should be_empty
      @tag.save
      
      Tag.all.size.should     == 1
      Tagging.all.size.should == 0
      Photo.all.size.should   == 0
    end
    
  end
  
  describe "every accessible has(n, :through) renamed association with no reject_if proc", :shared => true do
    
    it "should allow to create a new picture via Tag#pictures_attributes" do
      @tag.save
      Tag.all.size.should     == 1
      Tagging.all.size.should == 0
      Photo.all.size.should   == 0
      
      @tag.pictures_attributes = { 'new_1' => { :name => 'dm-accepts_nested_attributes' } }
      @tag.pictures.should_not be_empty
      @tag.pictures.first.name.should == 'dm-accepts_nested_attributes'
      @tag.save
      @tag.pictures.first.should == Photo.first
      
      Tag.all.size.should     == 1
      Tagging.all.size.should == 1
      Photo.all.size.should   == 1
      
      Photo.first.name.should == 'dm-accepts_nested_attributes'
    end
        
    it "should allow to update an existing picture via Tag#pictures_attributes" do
      @tag.save
      photo = Photo.create(:name => 'dm-accepts_nested_attributes')
      tagging = Tagging.create(:tag => @tag, :photo => photo)
      Tag.all.size.should     == 1
      Photo.all.size.should   == 1
      Tagging.all.size.should == 1
      
      @tag.reload
      
      @tag.pictures_attributes = { photo.id.to_s => { :id => photo.id, :name => 'still dm-accepts_nested_attributes' } }
      @tag.pictures.should_not be_empty
      @tag.pictures.first.name.should == 'still dm-accepts_nested_attributes'
      @tag.save
      
      Tag.all.size.should     == 1
      Tagging.all.size.should == 1
      Photo.all.size.should   == 1
      
      Photo.first.name.should == 'still dm-accepts_nested_attributes'
    end
    
    it "should perform atomic commits" do
      
      @tag.pictures_attributes = { 'new_1' => { :name => nil } } # should fail because of validations
      @tag.pictures.should be_empty
      @tag.save
      @tag.pictures.should be_empty
      
      Tag.all.size.should     == 1
      Tagging.all.size.should == 0
      Photo.all.size.should   == 0
      
      Tag.all.destroy! # TODO refactor specs into more it blocks
      
      @tag.name = nil # should fail because of validations
      @tag.pictures_attributes = { 'new_1' => { :name => 'beach' } }
      @tag.pictures.should be_empty
      @tag.save
      @tag.pictures.should be_empty
      
      Tag.all.size.should     == 0
      Tagging.all.size.should == 0
      Photo.all.size.should   == 0
      
    end
    
  end
  
  describe "every accessible has(n, :through) renamed association with :allow_destroy => false", :shared => true do
    
    it "should not allow to delete an existing picture via Tag#pictures_attributes" do
      @tag.save
      photo = Photo.create(:name => 'dm-accepts_nested_attributes')
      tagging = Tagging.create(:tag => @tag, :photo => photo)
      
      Tag.all.size.should     == 1
      Tagging.all.size.should == 1
      Photo.all.size.should   == 1
    
      @tag.reload
      @tag.pictures_attributes = { '1' => { :id => photo.id, :_delete => true } }
      @tag.save
      
      Tag.all.size.should     == 1
      Tagging.all.size.should == 1
      Photo.all.size.should   == 1
    end
    
  end
  
  describe "every accessible has(n, :through) renamed association with :allow_destroy => true", :shared => true do
    
    it "should allow to delete an existing picture via Tag#pictures_attributes" do
      @tag.save
      photo = Photo.create(:name => 'dm-accepts_nested_attributes')
      tagging = Tagging.create(:tag => @tag, :photo => photo)
      
      Tag.all.size.should     == 1
      Tagging.all.size.should == 1
      Photo.all.size.should   == 1
    
      @tag.reload
      @tag.pictures_attributes = { '1' => { :id => photo.id, :_delete => true } }
      @tag.save
      
      Tag.all.size.should     == 1
      Tagging.all.size.should == 0
      Photo.all.size.should   == 0
    end
    
  end

  describe "every accessible has(n, :through) renamed association with a nested attributes reader", :shared => true do

    it "should return the attributes written to Tag#pictures_attributes from the Tag#pictures_attributes reader" do
      @tag.pictures_attributes.should be_nil

      @tag.pictures_attributes = { 'new_1' => { :name => 'write specs' } }

      @tag.pictures_attributes.should == { 'new_1' => { :name => 'write specs' } }
    end

  end
  
  describe "Tag.has(n, :pictures, :through => :taggings) renamed" do
  
    describe "accepts_nested_attributes_for(:pictures)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Tag.accepts_nested_attributes_for :pictures
        @tag = Tag.new :name => 'snusnu'
      end
      
      it_should_behave_like "every accessible has(n, :through) renamed association with no reject_if proc"
      it_should_behave_like "every accessible has(n, :through) renamed association with :allow_destroy => false"
      it_should_behave_like "every accessible has(n, :through) renamed association with a nested attributes reader"
      
    end
      
    describe "accepts_nested_attributes_for(:pictures, :allow_destroy => false)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Tag.accepts_nested_attributes_for :pictures, :allow_destroy => false
        @tag = Tag.new :name => 'snusnu'
      end
      
      it_should_behave_like "every accessible has(n, :through) renamed association with no reject_if proc"
      it_should_behave_like "every accessible has(n, :through) renamed association with :allow_destroy => false"
      
    end
        
    describe "accepts_nested_attributes_for(:pictures, :allow_destroy = true)" do
      
      before(:each) do
        DataMapper.auto_migrate!
        Tag.accepts_nested_attributes_for :pictures, :allow_destroy => true
        @tag = Tag.new :name => 'snusnu'
      end
      
      it_should_behave_like "every accessible has(n, :through) renamed association with no reject_if proc"
      it_should_behave_like "every accessible has(n, :through) renamed association with :allow_destroy => true"
      
    end
    
    describe "accepts_nested_attributes_for :pictures, " do
      
      describe ":reject_if => :foo" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Tag.accepts_nested_attributes_for :pictures, :reject_if => :foo
          @tag = Tag.new :name => 'snusnu'
        end
    
        it_should_behave_like "every accessible has(n, :through) renamed association with no reject_if proc"
        it_should_behave_like "every accessible has(n, :through) renamed association with :allow_destroy => false"
      
      end
            
      describe ":reject_if => lambda { |attrs| true }" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Tag.accepts_nested_attributes_for :pictures, :reject_if => lambda { |attrs| true }
          @tag = Tag.new :name => 'snusnu'
        end
    
        it_should_behave_like "every accessible has(n, :through) renamed association with a valid reject_if proc"
        it_should_behave_like "every accessible has(n, :through) renamed association with :allow_destroy => false"
      
      end
                  
      describe ":reject_if => lambda { |attrs| false }" do
    
        before(:each) do
          DataMapper.auto_migrate!
          Tag.accepts_nested_attributes_for :pictures, :reject_if => lambda { |attrs| false }
          @tag = Tag.new :name => 'snusnu'
        end
    
        it_should_behave_like "every accessible has(n, :through) renamed association with no reject_if proc"
        it_should_behave_like "every accessible has(n, :through) renamed association with :allow_destroy => false"
      
      end
    
    end
    
  end
  
end
