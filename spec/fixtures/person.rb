class Person

  include DataMapper::Resource
  extend ConstraintSupport

  # properties

  property :id,   Serial
  property :name, String, :nullable => false

  # associations

  has 1, :profile,
    constraint_options(:destroy)

  has 1, :address,
   :through => :profile

  has n, :project_memberships,
    constraint_options(:destroy)

  has n, :projects,
    :through => :project_memberships

  has n, :tasks,
    :through => :projects

end
