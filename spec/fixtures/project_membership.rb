class ProjectMembership

  include DataMapper::Resource

  # properties

  property :id,         Serial
  property :person_id,  Integer, :nullable => false, :min => 0
  property :project_id, Integer, :nullable => false, :min => 0

  # associations

  belongs_to :person
  belongs_to :project

end
