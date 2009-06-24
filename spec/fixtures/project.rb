class Project
  
  include DataMapper::Resource
  
  # properties
  
  property :id,   Serial
  property :name, String, :nullable => false
  
  # associations
  
  has n, :tasks,
    :constraint => :destroy

  has n, :project_memberships,
    :constraint => :destroy

  has n, :people,
    :through => :project_memberships

end