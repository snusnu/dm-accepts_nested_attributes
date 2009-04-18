class Tagging
  include DataMapper::Resource

  property :id,       Serial
  property :tag_id,   Integer, :nullable => false
  property :photo_id, Integer, :nullable => false

  belongs_to :tag
  belongs_to :photo
end
