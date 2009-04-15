class ProjectMembership
  include DataMapper::Resource
  property :id,         Serial
  property :person_id,  Integer, :nullable => false
  property :project_id, Integer, :nullable => false
  belongs_to :person
  belongs_to :project
end