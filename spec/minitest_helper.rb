require 'minitest/autorun'

require 'dm-accepts_nested_attributes'

class Source
  include DataMapper::Resource
  property :id, Serial
  has n, :targets
end

class Target
  include DataMapper::Resource
  property :id, Serial
  belongs_to :source
end

class Project
  include DataMapper::Resource

  property :id, Integer, :key => true, :min => 0

  has n, :memberships
  has n, :people, :through => :memberships
end

class Person
  include DataMapper::Resource

  property :id, Integer, :key => true, :min => 0

  has n, :memberships
  has n, :projects, :through => :memberships

  accepts_nested_attributes_for :memberships, :allow_destroy => true
end

class Membership
  include DataMapper::Resource

  property :person_id, Integer, :key => true, :min => 0
  property :project_id, Integer, :key => true, :min => 0

  belongs_to :person
  belongs_to :project

  accepts_nested_attributes_for :person
  accepts_nested_attributes_for :project
end
