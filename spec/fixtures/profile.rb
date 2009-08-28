class Profile

  include DataMapper::Resource

  # properties

  property :id,        Serial
  property :person_id, Integer, :nullable => false, :min => 0

  property :nick,      String,  :nullable => false

  # associations

  belongs_to :person

  has 1, :address

end
