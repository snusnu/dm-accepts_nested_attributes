class ProjectMembership

  include DataMapper::Resource

  # properties

  property :id,         Serial
  property :person_id,  Integer, :nullable => false
  property :project_id, Integer, :nullable => false

  # associations

  belongs_to :person
  belongs_to :project

end
