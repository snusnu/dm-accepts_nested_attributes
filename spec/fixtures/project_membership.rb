class ProjectMembership

  include DataMapper::Resource

  # properties

  property :id,         Serial
  property :person_id,  Integer, :required => true, :min => 0
  property :project_id, Integer, :required => true, :min => 0

  # associations

  belongs_to :person
  belongs_to :project

end
