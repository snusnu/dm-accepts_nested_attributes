class Address

  include DataMapper::Resource

  property :id,         Serial
  property :profile_id, Integer, :required => true, :unique => true, :unique_index => true, :min => 0
  property :body,       String,  :required => true

  belongs_to :profile

  has 1, :person,
    :through => :profile

end
