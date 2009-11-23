class Task

  include DataMapper::Resource

  # properties

  property :id,         Serial
  property :project_id, Integer, :required => true, :min => 0

  property :name,       String,  :required => true

  # associations

  belongs_to :project

end
