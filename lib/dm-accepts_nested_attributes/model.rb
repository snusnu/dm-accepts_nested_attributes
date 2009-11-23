module DataMapper
  module NestedAttributes

    ##
    # Named plugin exception that gets raised by
    # @see accepts_nested_attributes_for
    # if the passed options don't make sense
    class InvalidOptions < ArgumentError; end

    module Model

      ##
      # Allows any association to accept nested attributes.
      #
      # @param [Symbol, String] association_name
      #   The name of the association that should accept nested attributes
      #
      # @param [Hash, nil] options
      #   List of resources to initialize the Collection with
      #
      # @option [Symbol, String, #call] :reject_if
      #   An instance method name or an object that respond_to?(:call), which
      #   stops a new record from being created, if it evaluates to true.
      #
      # @option [true, false] :allow_destroy
      #   If true, allow destroying the association via the generated writer
      #   If false, prevent destroying the association via the generated writer
      #   defaults to false
      #
      # @raise [DataMapper::NestedAttributes::InvalidOptions]
      #   A named exception class indicating invalid options
      #
      # @return nil
      #
      def accepts_nested_attributes_for(association_name, options = {})

        # ----------------------------------------------------------------------------------
        #                      try to fail as early as possible
        # ----------------------------------------------------------------------------------

        unless relationship = relationships(repository_name)[association_name]
          raise(ArgumentError, "No relationship #{association_name.inspect} for '#{name}' in :#{repository_name} repository")
        end

        # raise InvalidOptions if the given options don't make sense
        assert_valid_options_for_nested_attributes(options)

        # by default, nested attributes can't be destroyed
        options = { :allow_destroy => false }.update(options)

        # ----------------------------------------------------------------------------------
        #                       should be safe to go from here
        # ----------------------------------------------------------------------------------

        options_for_nested_attributes[relationship] = options

        include ::DataMapper::NestedAttributes::Resource

        # TODO i wonder if this is the best place here?
        # the transactional save behavior is definitely not needed for all resources,
        # but it's necessary for resources that accept nested attributes
        # FIXME this leads to weird "no such table" errors when specs are run
        add_transactional_save_behavior # TODO if repository.adapter.supports_transactions?

        # TODO make this do something
        # it's only here now to remind me that this is probably the best place to put it
        add_error_collection_behavior if DataMapper.const_defined?('Validate')

        type = relationship.max > 1 ? :collection : :resource

        define_method "#{association_name}_attributes" do
          instance_variable_get("@#{association_name}_attributes")
        end

        define_method "#{association_name}_attributes=" do |attributes|
          attributes = sanitize_nested_attributes(attributes)
          instance_variable_set("@#{association_name}_attributes", attributes)
          send("assign_nested_attributes_for_related_#{type}", relationship, attributes)
        end

      end

      def options_for_nested_attributes
        @options_for_nested_attributes ||= {}
      end


      private

      ##
      # Provides a hook to include or disable customized transactional save behavior.
      # Override this method to customize the implementation or disable it altogether.
      # The current implementation in @see DataMapper::NestedAttributes::TransactionalSave
      # simply wraps the saving of the complete object tree inside a transaction
      # and rolls back in case any exceptions are raised, or any of the calls to
      # @see DataMapper::Resource#save returned false
      #
      # @return Not specified
      #
      def add_transactional_save_behavior
        require 'dm-accepts_nested_attributes/transactional_save'
        include ::DataMapper::NestedAttributes::TransactionalSave
      end

      ##
      # Provides a hook to include or disable customized error collecting behavior.
      # Overwrite this method to customize the implementation or disable it altogether.
      # The current implementation in @see DataMapper::NestedAttributes::ValidationErrorCollecting
      # simply attaches all errors of related resources to the object that was initially saved.
      #
      # @return Not specified
      #
      def add_error_collection_behavior
        require 'dm-accepts_nested_attributes/error_collecting'
        include ::DataMapper::NestedAttributes::ValidationErrorCollecting
      end

      ##
      # Checks options passed to @see accepts_nested_attributes_for
      # If any of the given options is invalid, this method will raise
      # @see DataMapper::NestedAttributes::InvalidOptions
      #
      # @param [Hash, nil] options
      #   The options passed to @see accepts_nested_attributes_for
      #
      # @raise [DataMapper::NestedAttributes::InvalidOptions]
      #   A named exception class indicating invalid options
      #
      # @return [nil]
      #
      def assert_valid_options_for_nested_attributes(options)

        assert_kind_of 'options', options, Hash

        valid_options = [ :allow_destroy, :reject_if ]

        unless options.all? { |k,v| valid_options.include?(k) }
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
end
