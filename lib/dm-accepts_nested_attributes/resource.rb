module DataMapper
  module NestedAttributes

    ##
    # Extensions and customizations for a {DataMapper::Resource}
    # that are needed if the {DataMapper::Resource} wants to
    # accept nested attributes for any given relationship.
    # Basically, this module provides functionality that allows
    # either assignment or marking for destruction of related parent
    # and child associations, based on the given attributes and what
    # kind of relationship should be altered.
    module Resource
      # Truthy values for the +:_delete+ flag.
      TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].to_set

      ##
      # Can be used to remove ambiguities from the passed attributes.
      # Consider a situation with a belongs_to association where both a valid value
      # for the foreign_key attribute *and* nested_attributes for a new record are
      # present (i.e. item_type_id and item_type_attributes are present).
      # Also see http://is.gd/sz2d on the rails-core ml for a discussion on this.
      # The basic idea is, that there should be a well defined behavior for what
      # exactly happens when such a situation occurs. I'm currently in favor for
      # using the foreign_key if it is present, but this probably needs more thinking.
      # For now, this method basically is a no-op, but at least it provides a hook where
      # everyone can perform it's own sanitization by overwriting this method.
      #
      # @param attributes [Hash]
      #   The attributes to sanitize.
      #
      # @return [Hash]
      #   The sanitized attributes.
      #
      def sanitize_nested_attributes(attributes)
        attributes # noop
      end

      ##
      # Saves the resource and destroys nested resources marked for destruction.
      def save(*)
        saved = super
        remove_destroyables
        saved
      end

      private

      ##
      # Attribute hash keys that are excluded when creating a nested resource.
      # Excluded attributes include +:_delete+, a special value used to mark a
      # resource for destruction.
      #
      # @return [Array<Symbol>] Excluded attribute names.
      def uncreatable_keys
        [:_delete]
      end

      ##
      # Attribute hash keys that are excluded when updating a nested resource.
      # Excluded attributes include the model key and :_delete, a special value
      # used to mark a resource for destruction.
      #
      # @return [Array<Symbol>] Excluded attribute names.
      def unupdatable_keys
        model.key.to_a.map { |property| property.name } << :_delete
      end


      ##
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
      # @param relationship [DataMapper::Associations::Relationship]
      #   The relationship backing the association.
      #   Assignment will happen on the target end of the relationship
      #
      # @param attributes [Hash{Symbol => Object}]
      #   The attributes to assign to the relationship's target end.
      #   All attributes except {#uncreatable_keys} (for new resources) and
      #   {#unupdatable_keys} (when updating an existing resource) will be
      #   assigned.
      #
      # @return [void]
      def assign_nested_attributes_for_related_resource(relationship, attributes)
        assert_kind_of 'attributes', attributes, Hash

        if keys = extract_keys(relationship, attributes)
          existing_record = relationship.get(self)
          if existing_record && existing_record.key == keys
            update_or_mark_as_destroyable(relationship, existing_record, attributes)
            return
          end
        end

        return if reject_new_record?(relationship, attributes)

        attributes = DataMapper::Ext::Hash.except(attributes, *uncreatable_keys)
        new_record = relationship.target_model.new(attributes)
        relationship.set(self, new_record)
      end

      ##
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
      # @param relationship [DataMapper::Associations::Relationship]
      #   The relationship backing the association.
      #   Assignment will happen on the target end of the relationship
      #
      # @param attributes_collection [Hash{Integer=>Hash}, Array<Hash>]
      #   The attributes to assign to the relationship's target end.
      #   All attributes except {#uncreatable_keys} (for new resources) and
      #   {#unupdatable_keys} (when updating an existing resource) will be
      #   assigned.
      #
      # @return [void]
      def assign_nested_attributes_for_related_collection(relationship, attributes_collection)
        assert_hash_or_array_of_hashes("attributes_collection", attributes_collection)

        normalize_attributes_collection(attributes_collection).each do |attributes|
          if keys = extract_keys(relationship, attributes)
            collection = relationship.get(self)
            if existing_record = collection.get(*keys)
              update_or_mark_as_destroyable(relationship, existing_record, attributes)
              next
            end
          end

          next if reject_new_record?(relationship, attributes)

          attributes = DataMapper::Ext::Hash.except(attributes, *uncreatable_keys)
          relationship.get(self).new(attributes)
        end

        nil
      end

      ##
      # Extracts the primary key values necessary to retrieve or update a nested
      # model when using +accepts_nested_attributes_for+. Values are taken from
      # this model instance and attribute hash with the former having priority.
      # Values for properties in the primary key that are *not* included in the
      # foreign key must be specified in the attributes hash.
      #
      # @param relationship [DataMapper::Association::Relationship]
      #   The relationship backing the association.
      #
      # @param attributes [Hash{Symbol => Object}]
      #   The attributes assigned to the nested attribute setter on the
      #   +model+.
      #
      # @return [Array]
      def extract_keys(relationship, attributes)
        relationship.extract_keys_for_nested_attributes(self, attributes)
      end

      ##
      # Updates a record with the +attributes+ or marks it for destruction if
      # the +:allow_destroy+ option is +true+ and {#has_delete_flag?} returns
      # +true+.
      #
      # @param relationship [DataMapper::Associations::Relationship]
      #   The relationship backing the association.
      #   Assignment will happen on the target end of the relationship
      #
      # @param attributes [Hash{Symbol => Object}]
      #   The attributes to assign to the relationship's target end.
      #   All attributes except {#unupdatable_keys} will be assigned.
      #
      # @return [void]
      def update_or_mark_as_destroyable(relationship, resource, attributes)
        allow_destroy = self.class.options_for_nested_attributes[relationship.name][:allow_destroy]
        if has_delete_flag?(attributes) && allow_destroy
          if relationship.is_a?(DataMapper::Associations::ManyToMany::Relationship)
            intermediaries = relationship.through.get(self).all(relationship.via => resource)
            intermediaries.each { |intermediate| destroyables << intermediate }
          end
          destroyables << resource
        else
          assert_nested_update_clean_only(resource)
          resource.attributes = DataMapper::Ext::Hash.except(attributes, *unupdatable_keys)
          resource.save
        end
      end

      ##
      # Determines whether the given attributes hash contains a truthy :_delete key.
      #
      # @param attributes [Hash{Symbol => Object}] The attributes to test.
      #
      # @return [Boolean]
      #   +true+ if attributes contains a truthy :_delete key.
      #
      # @see TRUE_VALUES
      def has_delete_flag?(attributes)
        value = attributes[:_delete]
        if value.is_a?(String) && value !~ /\S/
          nil
        else
          TRUE_VALUES.include?(value)
        end
      end

      ##
      # Determines if a new record should be built with the given attributes.
      # Rejects a new record if {#has_delete_flag?} returns +true+ for the given
      # attributes, or if a +:reject_if+ guard exists for the passed relationship
      # that evaluates to +true+.
      #
      # @param relationship [DataMapper::Associations::Relationship]
      #   The relationship backing the association.
      #
      # @param attributes [Hash{Symbol => Object}]
      #   The attributes to test with {#has_delete_flag?}.
      #
      # @return [Boolean]
      #   +true+ if the given attributes will be rejected.
      def reject_new_record?(relationship, attributes)
        guard = self.class.options_for_nested_attributes[relationship.name][:reject_if]
        return false if guard.nil? # if relationship guard is nil, nothing will be rejected
        has_delete_flag?(attributes) || evaluate_reject_new_record_guard(guard, attributes)
      end

      ##
      # Evaluates the given guard by calling it with the given attributes.
      #
      # @param [Symbol, String, #call] guard
      #   An instance method name or an object that respond_to?(:call), which
      #   would stop a new record from being created, if it evaluates to true.
      #
      # @param [Hash{Symbol => Object}] attributes
      #   The attributes to pass to the guard for evaluating if it should reject
      #   the creation of a new resource
      #
      # @raise [ArgumentError]
      #   If the given guard doesn't match [Symbol, String, #call]
      #
      # @return [Boolean]
      #   The value returned by evaluating the guard
      def evaluate_reject_new_record_guard(guard, attributes)
        if guard.is_a?(Symbol) || guard.is_a?(String)
          send(guard, attributes)
        elsif guard.respond_to?(:call)
          guard.call(attributes)
        else
          # never reached when called from inside the plugin
          raise ArgumentError, "guard must be a Symbol, a String, or respond_to?(:call)"
        end
      end

      ##
      # Raises an exception if the specified resource is dirty or has dirty
      # children.
      #
      # @param [DataMapper::Resource] resource
      #   The resource to check.
      #
      # @return [void]
      #
      # @raise [UpdateConflictError]
      #   If the resource is dirty.
      #
      # @api private
      def assert_nested_update_clean_only(resource)
        if resource.send(:dirty_self?) || resource.send(:dirty_children?)
          raise UpdateConflictError, "#{model}#update cannot be called on a #{new? ? 'new' : 'dirty'} nested resource"
        end
      end

      ##
      # Asserts that the specified parameter value is a Hash of Hashes, or an
      # Array of Hashes and raises an ArgumentError if value does not conform.
      #
      # @param param_name [String]
      #   The parameter name included in the raised ArgumentError.
      #
      # @param value
      #   The value to check.
      #
      # @return [void]
      def assert_hash_or_array_of_hashes(param_name, value)
       if value.is_a?(Hash)
          unless value.values.all? { |a| a.is_a?(Hash) }
            raise ArgumentError,
                  "+#{param_name}+ should be a Hash of Hashes or Array " +
                  "of Hashes, but was a Hash with #{value.values.map { |a| a.class }.uniq.inspect}"
          end
        elsif value.is_a?(Array)
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

      ##
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
          attributes.map { |_, attributes| attributes }
        else
          attributes
        end
      end


      def destroyables
        @destroyables ||= []
      end

      def remove_destroyables
        destroyables.each { |r| r.destroy if r.saved? }
        @destroyables.clear
      end

    end

  end
end
