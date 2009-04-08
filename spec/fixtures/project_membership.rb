class ProjectMembership
  include DataMapper::Resource
  property :id,         Serial
  property :person_id,  Integer
  property :project_id, Integer
  belongs_to :person
  belongs_to :project
end