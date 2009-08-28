class Task

  include DataMapper::Resource

  # properties

  property :id,         Serial
  property :project_id, Integer, :nullable => false, :min => 0

  property :name,       String,  :nullable => false

  # associations

  belongs_to :project

end
