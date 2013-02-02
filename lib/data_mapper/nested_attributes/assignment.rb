require 'data_mapper/nested_attributes/key_values_extractor'

module DataMapper
  module NestedAttributes
    class Assignment
      include Assertions

      attr_reader :assignee
      attr_reader :configuration

      def self.for(assignee, configuration)
        if configuration.collection?
          Assignment::Collection.new(assignee, configuration)
        else
          Assignment::Resource.new(assignee, configuration)
        end
      end

      # @param [DataMapper::NestedAttributes::Acceptor] configuration
      #   Acceptor whose configuration will guide this Assignment.
      #
      # @param [DataMapper::NestedAttributes::Resource] assignee
      #   Resource which is receiving the nested attribute assignment
      def initialize(assignee, configuration)
        @assignee      = assignee
        @configuration = configuration
      end

      # Assigns the given attributes to the resource association.
      #
      # If the given attributes include the primary key values that match the
      # existing record’s keys, then the existing record will be modified.
      # Otherwise a new record will be built.
      #
      # If the given attributes include matching primary key values _and_ a
      # <tt>:_delete</tt> key set to a truthy value, then the existing record
      # will be marked for destruction.
      #
      # The names of the primary key values required depend on the configuration
      # of the association. It is not necessary to specify values for attributes
      # that exist on this resource as they are inferred.
      #
      # @param [Hash{Symbol => Object}] attributes
      #   The attributes to assign to the relationship's target end.
      #   All attributes except {#uncreatable_keys} (for new resources) and
      #   {#unupdatable_keys} (when updating an existing resource) will be
      #   assigned.
      #
      # @return [void]
      def assign(attributes)
        assert_kind_of 'attributes', attributes, Hash

        if key_values = key_values_extractor.extract(attributes)
          if existing_resource = existing_resource_for_key_values(key_values)
            updater.update(existing_resource, attributes)
            return self
          end
        end

        if configuration.accept_new_resource?(assignee, attributes)
          new_resource = new_associated_resource
          filtered_attributes = creatable_attributes(new_resource, attributes)
          new_resource.attributes = filtered_attributes
        end

        self
      end

      private

      def key_values_extractor
        @key_values_extractor ||= configuration.key_values_extractor_for(assignee)
      end

      def updater
        @updater ||= configuration.updater_for(assignee)
      end

      def associated
        configuration.get_associated(assignee)
      end

      # Attribute hash keys that are excluded when creating a nested resource.
      # Excluded attributes include +:_delete+, a special value used to mark a
      # resource for destruction.
      #
      # @param [DataMapper::Resource] resource
      #   Resource for which +attributes+ will be filtered
      #
      # @param [Hash<Symbol => Object>] attributes
      #   Attributes to be filtered according to which of its keys are
      #   creatable in +resource+
      #
      # @return [Hash<Symbol => Object>]
      #   Filtered attributes which are valida for creating +resource+
      def creatable_attributes(resource, attributes)
        uncreatable_keys = configuration.uncreatable_keys(resource)
        DataMapper::Ext::Hash.except(attributes, *uncreatable_keys)
      end


      class Resource < Assignment
        private

        def existing_resource_for_key_values(key_values)
          existing = associated
          existing if existing && existing.key == key_values
        end

        def new_associated_resource
          new_resource = configuration.new_target_model_instance
          configuration.set_associated(assignee, new_resource)
          new_resource
        end
      end # class Resource

      class Collection < Assignment::Resource
        # Assigns the given attributes to the collection association.
        #
        # Hashes with primary key values matching an existing associated record
        # will update that record. Hashes without primary key values (or only
        # values for a partial primary key), or if no existing associated record
        # exists, will build a new record for the association. Hashes with
        # matching primary key values and a <tt>:_delete</tt> key set to a truthy
        # value will mark the matched record for destruction.
        #
        # The names of the primary key values required depend on the configuration
        # of the association. It is not necessary to specify values for attributes
        # that exist on this resource as they are inferred.
        #
        # For example:
        #
        #     assign_nested_attributes_for_collection_association(:people, {
        #       '1' => { :id => '1', :name => 'Peter' },
        #       '2' => { :name => 'John' },
        #       '3' => { :id => '2', :_delete => true }
        #     })
        #
        # Will update the name of the Person with ID 1, build a new associated
        # person with the name 'John', and mark the associatied Person with ID 2
        # for destruction.
        #
        #     assign_nested_attributes_for_collection_association(:people, {
        #       '1' => { :person_id => '1', :audit_id => 2, :name => 'Peter' },
        #       '2' => { :audit_id => 2, :name => 'John' },
        #       '3' => { :person_id => '2', :audit_id => 3, :_delete => true }
        #     })
        #
        # Will update the name of the Person with `(person_id, audit_id) = (1, 2)`,
        # build a new associated person with the name 'John', and mark the
        # associatied Person with key `(2, 3)` for destruction.
        #
        # Also accepts an Array of attribute hashes:
        #
        #     assign_nested_attributes_for_collection_association(:people, [
        #       { :id => '1', :name => 'Peter' },
        #       { :name => 'John' },
        #       { :id => '2', :_delete => true }
        #     ])
        #
        # @param [Hash{Integer=>Hash}, Array<Hash>] attributes
        #   The attributes to assign to the relationship's target end.
        #   All attributes except {#uncreatable_keys} (for new resources) and
        #   {#unupdatable_keys} (when updating an existing resource) will be
        #   assigned.
        #
        # @return [void]
        def assign(attributes)
          assert_hash_or_array_of_hashes("attributes", attributes)

          attributes_collection = normalize_attributes_collection(attributes)
          attributes_collection.each { |attrs| super(attrs) }

          self
        end

        private

        def existing_resource_for_key_values(key_values)
          associated.get(*key_values)
        end

        def new_associated_resource
          associated.new
        end

        # Make sure to return a collection of attribute hashes.
        # If passed an attributes hash, map it to its attributes.
        #
        # @param attributes [Hash, #each]
        #   An attributes hash or a collection of attribute hashes.
        #
        # @return [#each]
        #   A collection of attribute hashes.
        def normalize_attributes_collection(attributes)
          if attributes.is_a?(Hash)
            attributes.map { |_, attrs| attrs }
          else
            attributes
          end
        end

        # Asserts that the specified parameter value is a Hash of Hashes, or an
        # Array of Hashes and raises an ArgumentError if value does not conform.
        #
        # @param [String] param_name
        #   The parameter name included in the raised ArgumentError.
        #
        # @param value
        #   The value to check.
        #
        # @return [void]
        def assert_hash_or_array_of_hashes(param_name, value)
          case value
          when Hash
            unless value.values.all? { |a| a.is_a?(Hash) }
              raise ArgumentError,
                    "+#{param_name}+ should be a Hash of Hashes or Array " +
                    "of Hashes, but was a Hash with #{value.values.map { |a| a.class }.uniq.inspect}"
            end
          when Array
            unless value.all? { |a| a.is_a?(Hash) }
              raise ArgumentError,
                    "+#{param_name}+ should be a Hash of Hashes or Array " +
                    "of Hashes, but was an Array with #{value.map { |a| a.class }.uniq.inspect}"
            end
          else
            raise ArgumentError,
                  "+#{param_name}+ should be a Hash of Hashes or Array of " +
                  "Hashes, but was #{value.class}"
          end
        end

      end # class Collection

    end # class Assignment
  end # module NestedAttributes
end # module DataMapper
