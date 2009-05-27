module DataMapper
  module NestedAttributes
    
    # This exception will only be thrown from
    # the accepts_nested_attributes_for method
    # if the passed options don't make sense
    class InvalidOptions < ArgumentError; end
    
    module Model
    
      ##
      # Makes the named association accept nested attributes.
      #
      # @param [Symbol|String] association_name
      #   The name of the association that should accept nested attributes
      # @param [Hash] options (optional)
      #   List of resources to initialize the Collection with
      #
      # @return nil
      #
      # @api semipublic
      def accepts_nested_attributes_for(association_name, options = {})
        
        # ----------------------------------------------------------------------------------
        #                      try to fail as early as posssible
        # ----------------------------------------------------------------------------------
      
        assert_kind_of 'association_name', association_name, Symbol, String
        assert_kind_of 'options',          options,          Hash
        
        # by default, nested attributes can't be destroyed
        options = { :allow_destroy => false }.update(options)
        
        # raise InvalidOptions if the given options don't make sense
        assert_valid_options_for_nested_attributes(association_name, options)
        
        
        # ----------------------------------------------------------------------------------
        #                       should be safe to go from here
        # ----------------------------------------------------------------------------------
        
        # remember the given options
        options_for_nested_attributes[association_name] = options
        
        # include Resource functionality needed to accept nested attributes
        include ::DataMapper::NestedAttributes::Resource
        
        # add overriden save behavior that saves the complete loaded resource tree
        add_save_behavior(association_name, options)
        
        # add error collection behavior if dm-validations are present
        if DataMapper.const_defined?('Validate')
          add_error_collection_behavior(association_name, options)
        end
        
        # add transactional_save if transactions are supported by the adapter in use
        if true # TODO find out how to ask if the adapter supports transactions
          add_transactional_save_behavior(association_name, options)
        end
      
        # find out if we want to assign to a to_one or a to_many association
        type = relationship!(association_name).max > 1 ? :collection : :one_to_one
        
        
        # define accessors for the accepted nested attributes
        
        class_eval %{
        
          def #{association_name}_attributes
            @#{association_name}_attributes
          end
        
          def #{association_name}_attributes=(attributes)
            attributes = sanitize_nested_attributes(attributes)
            @#{association_name}_attributes = attributes
            assign_nested_attributes_for_#{type}_association(
              :#{association_name}, attributes, #{options[:allow_destroy]}
            )
          end

        }, __FILE__, __LINE__ + 1
      
      end
      
      
      # module only for structuring purposes
      # it gets included right below
      
      module RelationshipAccess

        def relationship(name, repository_name = default_repository_name)
          relationships(repository_name)[name]
        end

        def relationship!(name, repository_name = default_repository_name)
          unless relationship = relationship(name, repository_name)
            raise(ArgumentError, "No relationship #{name.inspect} for #{self.name} in #{repository_name}")
          end
          relationship
        end
      
      end
      
      include RelationshipAccess
    
      
      # options given to the accepts_nested_attributes method
      # guaranteed to be valid if they made it this far.
      def options_for_nested_attributes
        @options_for_nested_attributes ||= {}
      end
    
      # returns a Symbol, a String, or an object that responds_to :call
      # if there is an association called association_name
      # returns nil otherwise
      def reject_new_nested_attributes_guard_for(association_name)
        if options_for_nested_attributes[association_name]
          options_for_nested_attributes[association_name][:reject_if]
        end
      end


      private

      def add_save_behavior(association_name, options)
        require Pathname(__FILE__).dirname.expand_path + 'save'
        include ::DataMapper::NestedAttributes::Save
      end

      def add_transactional_save_behavior(association_name, options)
        require Pathname(__FILE__).dirname.expand_path + 'transactional_save'
        include ::DataMapper::NestedAttributes::TransactionalSave
      end

      def add_error_collection_behavior(association_name, options)
        require Pathname(__FILE__).dirname.expand_path + 'error_collecting'
        include ::DataMapper::NestedAttributes::ValidationErrorCollecting
      end
      
      
      def assert_valid_options_for_nested_attributes(association_name, options)
        
        unless relationships[association_name]
          raise(InvalidOptions, "Relationship #{name.inspect} does not exist in \#{self.name}")
        end

        unless options.all? { |k,v| [ :allow_destroy, :reject_if ].include?(k) }
          raise InvalidOptions, 'options must be one of :allow_destroy or :reject_if'
        end

        guard = options[:reject_if]
        if guard.is_a?(Symbol) || guard.is_a?(String)
          msg = ":reject_if => #{guard.inspect}, but there is no instance method #{guard.inspect} in #{self.name}"
          raise InvalidOptions, msg unless instance_methods.include?(options[:reject_if].to_s)
        else
          msg = ":reject_if must be a Symbol|String or respond_to?(:call) "
          raise InvalidOptions, msg unless guard.nil? || guard.respond_to?(:call)
        end
        
      end
  
    end
    
  end
  
  # Activate the plugin
  Model.append_extensions NestedAttributes::Model
  
end
