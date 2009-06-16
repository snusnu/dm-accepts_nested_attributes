module DataMapper
  module NestedAttributes
    
    module Resource
      
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
      # @return [Hash] The sanitized attributes
      def sanitize_nested_attributes(attributes)
        attributes # noop
      end
      
      private

      # Attribute hash keys that should not be assigned as normal attributes.
      # These hash keys are nested attributes implementation details.
      UNASSIGNABLE_KEYS = [ :id, :_delete ]
    
    
      ##
      # Assigns the given attributes to the resource association.
      #
      # If the given attributes include an <tt>:id</tt> that matches the existing
      # record’s id, then the existing record will be modified. Otherwise a new
      # record will be built.
      #
      # If the given attributes include a matching <tt>:id</tt> attribute _and_ a
      # <tt>:_delete</tt> key set to a truthy value, then the existing record
      # will be marked for destruction.
      #
      # @param relationship [DataMapper::Associations::Relationship]
      #   The relationship backing the association. 
      #   Assignment will happen on the target end of the relationship
      #
      # @param attributes [Hash]
      #   The attributes to assign to the relationship's target end
      #   All attributes except @see UNASSIGNABLE_KEYS will be assigned
      #
      # @return nil
      def assign_nested_attributes_for_related_resource(relationship, attributes)
        if attributes[:id].blank?
          return if reject_new_record?(relationship, attributes)
          new_record = relationship.target_model.new(attributes.except(*UNASSIGNABLE_KEYS))
          relationship.set(self, new_record)
        else
          existing_record = relationship.get(self)
          if existing_record && existing_record.id.to_s == attributes[:id].to_s
            assign_to_or_mark_for_destruction(relationship, existing_record, attributes)
          end
        end
      end
    
      ##
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
      #
      # @param relationship [DataMapper::Associations::Relationship]
      #   The relationship backing the association. 
      #   Assignment will happen on the target end of the relationship
      #
      # @param attributes [Hash]
      #   The attributes to assign to the relationship's target end
      #   All attributes except @see UNASSIGNABLE_KEYS will be assigned
      #
      # @return nil
      def assign_nested_attributes_for_related_collection(relationship, attributes_collection)
      
        normalize_attributes_collection(attributes_collection).each do |attributes|
          
          if attributes[:id].blank?
            next if reject_new_record?(relationship, attributes)
            relationship.get(self).new(attributes.except(*UNASSIGNABLE_KEYS))
          else
            collection = relationship.get(self)
            if existing_record = collection.detect { |record| record.id.to_s == attributes[:id].to_s }
              assign_to_or_mark_for_destruction(relationship, existing_record, attributes)
            end
          end
          
        end
      
      end
    
      ##
      # Updates a record with the +attributes+ or marks it for destruction if
      # +allow_destroy+ is +true+ and has_delete_flag? returns +true+.
      #
      # @param relationship [DataMapper::Associations::Relationship]
      #   The relationship backing the association. 
      #   Assignment will happen on the target end of the relationship
      #
      # @param attributes [Hash]
      #   The attributes to assign to the relationship's target end
      #   All attributes except @see UNASSIGNABLE_KEYS will be assigned
      #
      # @return nil
      def assign_to_or_mark_for_destruction(relationship, resource, attributes)
        allow_destroy = self.class.options_for_nested_attributes[relationship][:allow_destroy]
        if has_delete_flag?(attributes) && allow_destroy
          resource.mark_for_destruction
        else
          resource.update(attributes.except(*UNASSIGNABLE_KEYS))
        end
      end

      ##
      # Determines if a hash contains a truthy _delete key.
      #
      # @param hash [Hash] The hash to test
      #
      # @return [Boolean]
      #   true, if hash containts a truthy _delete key
      #   false, otherwise
      def has_delete_flag?(hash)
        # TODO find out if this activerecord code needs to be ported
        # ConnectionAdapters::Column.value_to_boolean hash['_delete']
        hash[:_delete]
      end
    
      ##
      # Determines if a new record should be build by checking for
      # has_delete_flag? or if a <tt>:reject_if</tt> proc exists for this
      # association and evaluates to +true+.
      #
      # @param relationship [DataMapper::Associations::Relationship]
      #   The relationship backing the association. 
      #   Assignment will happen on the target end of the relationship
      #
      # @param attributes [Hash]
      #   The attributes to assign to the relationship's target end
      #   All attributes except @see UNASSIGNABLE_KEYS will be assigned
      #
      # @return [Boolean]
      #   true, if the given attributes won't be rejected
      #   false, otherwise
      def reject_new_record?(relationship, attributes)
        guard = self.class.options_for_nested_attributes[relationship][:reject_if]
        return false if guard.nil? # if relationship guard is nil, nothing will be rejected
        has_delete_flag?(attributes) || evaluate_reject_new_record_guard(guard, attributes)
      end
      
      def evaluate_reject_new_record_guard(guard, attributes)
        if guard.is_a?(Symbol) || guard.is_a?(String)
          send(guard)
        elsif guard.respond_to?(:call)
          guard.call(attributes)
        else
          # never reached when called from inside the plugin
          raise ArgumentError, "guard must be a Symbol, a String, or respond_to?(:call)"
        end
      end
      
      def normalize_attributes_collection(attributes_collection)
        if attributes_collection.is_a?(Hash)
          attributes_collection.sort_by { |index, _| index.to_i }.map { |_, attributes| attributes }
        else
          attributes_collection
        end
      end
      
    end
    
    module CommonResourceSupport

      ##
      # remove mark for destruction if present
      # before delegating reload behavior to super
      #
      # @return The same value that super returns
      def reload
        @marked_for_destruction = false
        super
      end

      ##
      # Test if this resource is marked for destruction
      #
      # @return [Boolean]
      #   true, if this resource is marked for destruction
      #   false, otherwise
      def marked_for_destruction?
        @marked_for_destruction
      end

      ##
      # Mark this resource for destruction
      #
      # @return true
      def mark_for_destruction
        @marked_for_destruction = true
      end

    end

  end
end
