module DataMapper
  module NestedAttributes
    class BackwardsCompatibilityHash < Hash
      def initialize(model)
        @model = model
      end

      def [](key)
        if key.is_a?(DataMapper::Associations::Relationship)
          warn "#{@model}#options_for_nested_attributes: Using a relationship " +
               "as key is deprecated. Use the relationship name (i.e. " +
               "#{key.name.inspect}) as key."
          key = key.name
        end
        super(key)
      end

      def []=(key, value)
        if key.is_a?(DataMapper::Associations::Relationship)
          warn "#{@model}#options_for_nested_attributes: Using a relationship " +
               "as key is deprecated. Use the relationship name (i.e. " +
               "#{key.name.inspect}) as key."
          key = key.name
        end
        super(key, value)
      end
    end

    ##
    # Named plugin exception that is raised by {Model#accepts_nested_attributes_for}
    # if the passed options are invalid.
    class InvalidOptions < ArgumentError; end

    module Model

      ##
      # Allows an association to accept nested attributes.
      #
      # @param [Symbol, String] association_name
      #   The name of the association that should accept nested attributes.
      #
      # @param [Hash?] options
      #   List of resources to initialize the collection with.
      #
      # @option options [Symbol, String, #call] :reject_if
      #   An instance method name or an object that respond_to?(:call), which
      #   stops a new record from being created, if it evaluates to true.
      #
      # @option options [Boolean] :allow_destroy (false)
      #   If true, allows destroying the association via the generated writer.
      #   If false, prevents destroying the association via the generated writer.
      #
      # @raise [DataMapper::NestedAttributes::InvalidOptions]
      #   A named exception class indicating invalid options.
      #
      # @return [void]
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

        options_for_nested_attributes[relationship.name] = options

        include ::DataMapper::NestedAttributes::Resource

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

      # Returns a hash with the options for all associations (using the
      # corresponding relationship as key) that accept nested attributes.
      #
      # @return [Hash{DataMapper::Associations::Relationship => Hash}]
      def options_for_nested_attributes
        @options_for_nested_attributes ||= DataMapper::NestedAttributes::BackwardsCompatibilityHash.new(self)
      end


      private

      ##
      # Checks options passed to {#accepts_nested_attributes_for}.
      # If any of the given options is invalid, this method will raise
      # {DataMapper::NestedAttributes::InvalidOptions}.
      #
      # @param [Hash?] options
      #   The options passed to {#accepts_nested_attributes_for}.
      #
      # @raise [DataMapper::NestedAttributes::InvalidOptions]
      #   A named exception class indicating invalid options.
      #
      # @return [void]
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
