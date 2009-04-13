class Tag
  include DataMapper::Resource

  property :id,   Serial
  property :name, String

  has n, :tagged_things,    :class_name => "Tagging"
  has n, :pictures,         :through      => :tagged_things,
                            :class_name   => 'Photo',
                            :child_key    => [:tag_id],
                            :remote_name  => :photo
end
