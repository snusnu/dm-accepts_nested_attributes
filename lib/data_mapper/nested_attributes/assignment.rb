require 'data_mapper/nested_attributes/key_values_extractor'

module DataMapper
  module NestedAttributes
    class Assignment
      include Assertions

      attr_reader :acceptor
      attr_reader :relationship
      attr_reader :assignee

      def self.for(acceptor, assignee)
        if acceptor.collection?
          Assignment::Collection.new(acceptor, assignee)
        else
          Assignment::Resource.new(acceptor, assignee)
        end
      end

      # @param [DataMapper::NestedAttributes::Acceptor] acceptor
      #   Acceptor whose configuration will guide this Assignment.
      # 
      # @param [DataMapper::NestedAttributes::Resource] assignee
      #   Resource which is receiving the nested attribute assignment
      def initialize(acceptor, assignee)
        @acceptor     = acceptor
        @relationship = acceptor.relationship
        @assignee     = assignee
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
            acceptor.update_or_mark_as_destroyable(assignee, existing_resource, attributes)
            return self
          end
        end

        unless acceptor.reject_new_resource?(assignee, attributes)
          assign_new_resource(attributes)
        end

        self
      end

      def key_values_extractor
        @key_values_extractor ||= acceptor.key_values_extractor_for(assignee)
      end

      class Resource < Assignment
        def existing_resource_for_key_values(key_values)
          existing_related = relationship.get(assignee)
          existing_related if existing_related && existing_related.key == key_values
        end

        def assign_new_resource(attributes)
          new_resource = relationship.target_model.new
          new_resource.attributes = acceptor.creatable_attributes(new_resource, attributes)
          relationship.set(assignee, new_resource)
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

        def existing_resource_for_key_values(key_values)
          collection.get(*key_values)
        end

        def assign_new_resource(attributes)
          new_resource = collection.new(attributes)
          new_resource.attributes = acceptor.creatable_attributes(new_resource, attributes)
          new_resource
        end

        def collection
          relationship.get(assignee)
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
