class Profile
  include DataMapper::Resource
  property :id,        Serial
  property :person_id, Integer, :nullable => false
  property :nick,      String
  belongs_to :person
end