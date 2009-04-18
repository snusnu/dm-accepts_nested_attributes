class Person
  include DataMapper::Resource
  property :id,   Serial
  property :name, String, :nullable => false
  has 1, :profile
  has n, :project_memberships
  has n, :projects, :through => :project_memberships
end