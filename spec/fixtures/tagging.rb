class Tagging
  include DataMapper::Resource

  property :id,         Serial
  property :tag_id,     Integer
  property :photo_id,   Integer

  belongs_to :tag
  belongs_to :photo
end
