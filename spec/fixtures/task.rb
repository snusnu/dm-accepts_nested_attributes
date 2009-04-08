class Task
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
  property :project_id, Integer
  belongs_to :project
end