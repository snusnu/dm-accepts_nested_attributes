class Person
  
  include DataMapper::Resource
  
  # properties
  
  property :id,   Serial
  property :name, String, :nullable => false
  
  # associations
  
  has 1, :profile,
    :constraint => :destroy

  has n, :project_memberships,
    :constraint => :destroy

  has n, :projects,
    :through => :project_memberships
  
end