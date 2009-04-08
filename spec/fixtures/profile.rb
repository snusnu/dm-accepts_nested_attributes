class Profile
  include DataMapper::Resource
  property :id,        Serial
  property :person_id, Integer
  property :nick,      String
  belongs_to :person
end