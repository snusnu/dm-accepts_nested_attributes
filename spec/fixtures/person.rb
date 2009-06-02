class Person
  
  include DataMapper::Resource
  
  # properties
  
  property :id,   Serial
  property :name, String, :nullable => false
  
  # associations
  
  has 1, :profile
  has n, :project_memberships
  has n, :projects, :through => :project_memberships
  
end