module DataMapper
  module NestedAttributes
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_inheritable_accessor :autosave_associations
      base.autosave_associations = {}
    end
    
    module ClassMethods
      
      # Defines an attributes writer for the specified association(s). If you
      # are using <tt>attr_protected</tt> or <tt>attr_accessible</tt>, then you
      # will need to add the attribute writer to the allowed list.
      #
      # Supported options:
      # [:allow_destroy]
      # If true, destroys any members from the attributes hash with a
      # <tt>_delete</tt> key and a value that evaluates to +true+
      # (eg. 1, '1', true, or 'true'). This option is off by default.
      # [:reject_if]
      # Allows you to specify a Proc that checks whether a record should be
      # built for a certain attribute hash. The hash is passed to the Proc
      # and the Proc should return either +true+ or +false+. When no Proc
      # is specified a record will be built for all attribute hashes that
      # do not have a <tt>_delete</tt> that evaluates to true.
      #
      # Examples:
      # # creates avatar_attributes=
      # accepts_nested_attributes_for :avatar, :reject_if => proc { |attributes| attributes['name'].blank? }
      # # creates avatar_attributes= and posts_attributes=
      # accepts_nested_attributes_for :avatar, :posts, :allow_destroy => true
      def accepts_nested_attributes_for(association_name, options = {})
        
        assert_kind_of 'association_name', association_name, Symbol, String
        assert_kind_of 'options',          options,          Hash
        
        options = { :allow_destroy => false }.update(options)
        
        # raises if the specified option keys aren't valid
        assert_valid_autosave_options(options)
        
        # raises if the specified association doesn't exist
        # we don't need the return value here, just the check
        # ------------------------------------------------------
        # also, when using the return value from this call to
        # replace association_name with association.name,
        # has(1, :through) are broken, because they seem to have
        # a different name
        
        association_for_name(association_name)
        
        autosave_associations[association_name] = options
        
        type = nr_of_possible_child_instances(association_name) > 1 ? :collection : :one_to_one
        
        class_eval %{
          def #{association_name}_attributes=(attributes)
          assign_nested_attributes_for_#{type}_association(:#{association_name}, attributes, #{options[:allow_destroy]})
          end
        }, __FILE__, __LINE__ + 1
        
      end
      
      def reject_new_nested_attributes_proc_for(association_name)
        autosave_associations[association_name] ? autosave_associations[association_name][:reject_if] : nil
      end
      
      
      # utility methods
      
      def nr_of_possible_child_instances(association_name, repository = :default)
        # belongs_to seems to generate no options[:max]
        association_for_name(association_name, repository).options[:max] || 1
      end
      
      # this is here only because there is no #build_#{association_name}
      # method in datamapper. maybe it's a good idea to add this one?
      # ----------------------------------------------------------------
      # TODO: this needs one of the following:
      # - more dm-core reading
      # - a different approach
      # - an api in dm-core
      # - dm-core next branch (investigate this)
      def associated_model_for_name(association_name, repository = :default)
        a = association_for_name(association_name, repository)
        if a.options[:max].nil? # belongs_to
          a.parent_model
        elsif a.options[:max] == 1 # has(1)
          a.child_model
        elsif a.options[:max] > 1 && !a.is_a?(DataMapper::Associations::RelationshipChain) # has(n)
          a.child_model
        elsif a.is_a?(DataMapper::Associations::RelationshipChain) # has(n, :through) MUST be checked after has(n) here
          Object.full_const_get(a.options[:child_model])
        else
          raise ArgumentError, "Unknown association type #{a.inspect}"
        end
      end

      # avoid nil access by always going through this
      # this method raises if the association named name is not established in this model
      def association_for_name(name, repository = :default)
        association = self.relationships(repository)[name]
        # TODO think about using a specific Error class like UnknownAssociationError
        raise(ArgumentError, "Relationship #{name.inspect} does not exist in \#{model}") unless association
        association
      end
      
      private
      
      # think about storing valid options in a classlevel constant
      def assert_valid_autosave_options(options)
        unless options.all? { |k,v| [ :allow_destroy, :reject_if ].include?(k) }
          raise ArgumentError, 'accepts_nested_attributes_for only takes :allow_destroy and :reject_if as options'
        end
      end
  
    end
    
    
    # instance methods
    
    # returns nil if no resource has been associated yet
    def associated_instance_get(association_name, repository = :default)
      send(self.class.association_for_name(association_name, repository).name)
    end


    private

    # Attribute hash keys that should not be assigned as normal attributes.
    # These hash keys are nested attributes implementation details.
    UNASSIGNABLE_KEYS = [ :id, :_delete ]
    
    
    # Assigns the given attributes to the association.
    #
    # If the given attributes include an <tt>:id</tt> that matches the existing
    # record’s id, then the existing record will be modified. Otherwise a new
    # record will be built.
    #
    # If the given attributes include a matching <tt>:id</tt> attribute _and_ a
    # <tt>:_delete</tt> key set to a truthy value, then the existing record
    # will be marked for destruction.
    def assign_nested_attributes_for_one_to_one_association(association_name, attributes, allow_destroy)
      if attributes[:id].blank?
        unless reject_new_record?(association_name, attributes)
          model = self.class.associated_model_for_name(association_name)
          send("#{association_name}=", model.new(attributes.except(*UNASSIGNABLE_KEYS)))
        end
      elsif (existing_record = associated_instance_get(association_name)) && existing_record.id.to_s == attributes[:id].to_s
        assign_to_or_mark_for_destruction(existing_record, attributes, allow_destroy)
      end
    end
    
    # Assigns the given attributes to the collection association.
    #
    # Hashes with an <tt>:id</tt> value matching an existing associated record
    # will update that record. Hashes without an <tt>:id</tt> value will build
    # a new record for the association. Hashes with a matching <tt>:id</tt>
    # value and a <tt>:_delete</tt> key set to a truthy value will mark the
    # matched record for destruction.
    #
    # For example:
    #
    # assign_nested_attributes_for_collection_association(:people, {
    # '1' => { :id => '1', :name => 'Peter' },
    # '2' => { :name => 'John' },
    # '3' => { :id => '2', :_delete => true }
    # })
    #
    # Will update the name of the Person with ID 1, build a new associated
    # person with the name `John', and mark the associatied Person with ID 2
    # for destruction.
    #
    # Also accepts an Array of attribute hashes:
    #
    # assign_nested_attributes_for_collection_association(:people, [
    # { :id => '1', :name => 'Peter' },
    # { :name => 'John' },
    # { :id => '2', :_delete => true }
    # ])
    def assign_nested_attributes_for_collection_association(association_name, attributes_collection, allow_destroy)
      
      assert_kind_of 'association_name',      association_name,      Symbol
      assert_kind_of 'attributes_collection', attributes_collection, Hash, Array
       
      if attributes_collection.is_a? Hash
        attributes_collection = attributes_collection.sort_by { |index, _| index.to_i }.map { |_, attributes| attributes }
      end
       
      attributes_collection.each do |attributes|
        if attributes[:id].blank?
          unless reject_new_record?(association_name, attributes)
            send(association_name).build(attributes.except(*UNASSIGNABLE_KEYS))
          end
        elsif existing_record = send(association_name).detect { |record| record.id.to_s == attributes[:id].to_s }
          assign_to_or_mark_for_destruction(existing_record, attributes, allow_destroy)
        end
      end
      
    end
    
    # Updates a record with the +attributes+ or marks it for destruction if
    # +allow_destroy+ is +true+ and has_delete_flag? returns +true+.
    def assign_to_or_mark_for_destruction(record, attributes, allow_destroy)
      if has_delete_flag?(attributes) && allow_destroy
        record.mark_for_destruction
      else
        record.attributes = attributes.except(*UNASSIGNABLE_KEYS)
      end
    end
    
    # Determines if a hash contains a truthy _delete key.
    def has_delete_flag?(hash)
      # TODO find out if this activerecord code needs to be ported
      # ConnectionAdapters::Column.value_to_boolean hash['_delete']
      hash[:_delete]
    end
    
    # Determines if a new record should be build by checking for
    # has_delete_flag? or if a <tt>:reject_if</tt> proc exists for this
    # association and evaluates to +true+.
    def reject_new_record?(association_name, attributes)
      has_delete_flag?(attributes) ||
        self.class.reject_new_nested_attributes_proc_for(association_name).try_call(attributes)
    end

  end
end
