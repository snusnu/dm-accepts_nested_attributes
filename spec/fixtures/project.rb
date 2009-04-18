class Project
  include DataMapper::Resource
  property :id,   Serial
  property :name, String, :nullable => false
  has n, :tasks
  has n, :project_memberships
  has n, :people, :through => :project_memberships
end