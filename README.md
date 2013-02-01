# dm-accepts_nested_attributes

[![Build Status](https://travis-ci.org/snusnu/dm-accepts_nested_attributes.png?branch=release-1.2)](https://travis-ci.org/snusnu/dm-accepts_nested_attributes)

A DataMapper plugin that allows nested model attribute assignment like activerecord does.

Current documentation can always be found at [rdoc.info](http://rdoc.info/projects/snusnu/dm-accepts_nested_attributes)

## Examples

The following example illustrates the use of this plugin.

    require "rubygems"

    require "dm-core"
    require "dm-validations"
    require "dm-accepts_nested_attributes"

    DataMapper::Logger.new(STDOUT, :debug)
    DataMapper.setup(:default, 'sqlite3::memory:')

    # Specify the name of the key that marks a record
    # for deletion (defaults to :_delete)
    #
    # Can be overwritten on a per model basis by
    # passing :delete_key => :_my_delete_key to
    # Model.accepts_nested_attributes_for
    DataMapper::NestedAttributes.delete_key = :_destroy

    class Person
      include DataMapper::Resource
      property :id,   Serial
      property :name, String
      has 1, :profile
      has n, :project_memberships
      has n, :projects, :through => :project_memberships

      accepts_nested_attributes_for :profile
      accepts_nested_attributes_for :projects

      # adds the following instance methods
      # #profile_attributes=
      # #profile_attributes
      # #projects_attributes=
      # #projects_attributes
    end

    class Profile
      include DataMapper::Resource
      property :id,      Serial
      property :person_id, Integer
      belongs_to :person

      accepts_nested_attributes_for :person

      # adds the following instance methods
      # #person_attributes=
      # #person_attributes
    end

    class Project
      include DataMapper::Resource
      property :id, Serial
      has n, :tasks
      has n, :project_memberships
      has n, :people, :through => :project_memberships

      accepts_nested_attributes_for :tasks
      accepts_nested_attributes_for :people

      # adds the following instance methods
      # #tasks_attributes=
      # #tasks_attributes
      # #people_attributes=
      # #people_attributes
    end

    class ProjectMembership
      include DataMapper::Resource
      property :id,         Serial
      property :person_id,  Integer
      property :project_id, Integer
      belongs_to :person
      belongs_to :project
    end

    class Task
      include DataMapper::Resource
      property :id,         Serial
      property :project_id, Integer
      belongs_to :project
    end

    DataMapper.auto_migrate!

## TODO

* collect validation errors from related resources
* update README to include more complete usecases
* think about replacing :reject_if with :if and :unless
