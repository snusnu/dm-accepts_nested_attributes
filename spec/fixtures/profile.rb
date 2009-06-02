class Profile
  
  include DataMapper::Resource
  
  # properties
  
  property :id,        Serial
  property :person_id, Integer, :nullable => false
  
  property :nick,      String,  :nullable => false
  
  # associations
  
  belongs_to :person
  
end