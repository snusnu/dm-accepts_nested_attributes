module DataMapper
  module NestedAttributes
    
    module Resource
      
      # This method can be used to remove ambiguities from the passed attributes.
      # Consider a situation with a belongs_to association where both a valid value
      # for the foreign_key attribute *and* nested_attributes for a new record are
      # present (i.e. item_type_id and item_type_attributes are present).
      # Also see http://is.gd/sz2d on the rails-core ml for a discussion on this.
      # The basic idea is, that there should be a well defined behavior for what
      # exactly happens when such a situation occurs. I'm currently in favor for 
      # using the foreign_key if it is present, but this probably needs more thinking.
      # For now, this method basically is a no-op, but at least it provides a hook where
      # everyone can perform it's own sanitization (just overwrite this method) 
      def sanitize_nested_attributes(attrs)
        attrs # noop
      end
    
      # returns nil if no resource has been associated yet
      def associated_instance_get(association_name)
        send(relationships[association_name].name)
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
      def assign_nested_attributes_for_one_to_one_association(association_name, attrs, allow_destroy)
        if attrs[:id].blank?
          unless reject_new_record?(association_name, attrs)
            model = self.class.relationship!(association_name).target_model
            send("#{association_name}=", model.new(attrs.except(*UNASSIGNABLE_KEYS)))
          end
        else
          if (existing_record = associated_instance_get(association_name)) && existing_record.id.to_s == attrs[:id].to_s
            assign_to_or_mark_for_destruction(association_name, existing_record, attrs, allow_destroy)
          end
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
              case association = self.class.relationship!(association_name)
              when DataMapper::Associations::OneToMany::Relationship
                build_new_has_n_association(association_name, attributes)
              when DataMapper::Associations::ManyToMany::Relationship
                build_new_has_n_through_association(association_name, attributes)
              end
            end
          elsif existing_record = send(association_name).detect { |record| record.id.to_s == attributes[:id].to_s }
            assign_to_or_mark_for_destruction(association_name, existing_record, attributes, allow_destroy)
          end
        end
      
      end
    
      def build_new_has_n_association(association_name, attributes)
        send(association_name).new(attributes.except(*UNASSIGNABLE_KEYS))
      end
        
      def build_new_has_n_through_association(association_name, attributes)
        # fetch the association to have the information ready
        association = self.class.relationship!(association_name)
      
        # do what's done in dm-core/specs/integration/association_through_spec.rb
      
        # explicitly build the join entry and assign it to the join association
        join_entry = self.class.relationship!(association_name).target_model.new
        self.send(association.name) << join_entry
        self.save
        # explicitly build the child entry and assign the join entry to its join association
        child_entry = self.class.relationship!(association_name).target_model.new(attributes)
        child_entry.send(association.name) << join_entry
        child_entry.save
      end
    
      # Updates a record with the +attributes+ or marks it for destruction if
      # +allow_destroy+ is +true+ and has_delete_flag? returns +true+.
      def assign_to_or_mark_for_destruction(association_name, record, attributes, allow_destroy)
        if has_delete_flag?(attributes) && allow_destroy
          association = self.class.relationship!(association_name)
          if association.is_a?(DataMapper::Associations::ManyToMany::Relationship)
            # destroy the join record
            record.send(self.class.relationship!(association_name).name).destroy!
            # destroy the child record
            record.destroy
          else
            record.mark_for_destruction
          end
        else
          record.attributes = attributes.except(*UNASSIGNABLE_KEYS)
          association = self.class.relationship!(association_name)
          if association.is_a?(DataMapper::Associations::ManyToMany::Relationship)
            record.save
          end
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
        guard = self.class.reject_new_nested_attributes_guard_for(association_name)
        has_delete_flag?(attributes) || !evaluate_reject_new_record_guard(guard, attributes)
      end
      
      def evaluate_reject_new_record_guard(guard, attributes)
        return true if guard.nil?
        (guard.is_a?(Symbol) || guard.is_a?(String)) ? send(guard) : guard.call(attributes)
      end
      
    end
    
    module CommonResourceSupport

      # remove mark for destruction if present
      # before delegating reload behavior to super
      def reload
        @marked_for_destruction = false
        super
      end

      def marked_for_destruction?
        @marked_for_destruction
      end

      def mark_for_destruction
        @marked_for_destruction = true
      end

    end
    
    
    DataMapper::Model.append_inclusions(CommonResourceSupport)

  end
end
