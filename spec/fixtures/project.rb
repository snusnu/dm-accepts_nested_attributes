class Project
  
  include DataMapper::Resource
  
  # properties
  
  property :id,   Serial
  property :name, String, :nullable => false
  
  # associations
  
  has n, :tasks
  has n, :project_memberships
  has n, :people, :through => :project_memberships
  
end