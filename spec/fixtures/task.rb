class Task
  include DataMapper::Resource
  property :id,         Serial
  property :project_id, Integer, :nullable => false
  property :name,       String,  :nullable => false
  belongs_to :project
end