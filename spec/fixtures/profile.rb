class Profile

  include DataMapper::Resource

  # properties

  property :id,        Serial
  property :person_id, Integer, :required => true, :min => 0

  property :nick,      String,  :required => true

  # associations

  belongs_to :person

  has 1, :address

end
