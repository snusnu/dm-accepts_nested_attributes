class Project
  
  include DataMapper::Resource
  extend ConstraintSupport
  
  # properties
  
  property :id,   Serial
  property :name, String, :nullable => false
  
  # associations
  
  has n, :tasks,
    constraint_options(:destroy)

  has n, :project_memberships,
    constraint_options(:destroy)

  has n, :people,
    :through => :project_memberships

end