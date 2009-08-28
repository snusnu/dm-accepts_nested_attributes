class Address

  include DataMapper::Resource

  property :id,         Serial
  property :profile_id, Integer, :nullable => false, :unique => true, :unique_index => true, :min => 0
  property :body,       String,  :nullable => false

  belongs_to :profile

  has 1, :person,
    :through => :profile

end
