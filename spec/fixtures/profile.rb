class Profile
  include DataMapper::Resource
  property :id,        Serial
  property :person_id, Integer, :nullable => false
  property :nick,      String,  :nullable => false
  belongs_to :person
end