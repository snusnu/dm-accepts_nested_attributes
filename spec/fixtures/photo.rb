class Photo
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :nullable => false

  has n, :tagged_things, :class_name => "Tagging"
  has n, :tags, :through => :tagged_things
end
