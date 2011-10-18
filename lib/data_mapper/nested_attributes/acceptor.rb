require 'data_mapper/nested_attributes/assignment'
require 'data_mapper/nested_attributes/assignment/guard'

module DataMapper
  module NestedAttributes
    class Acceptor
      # Truthy values for the +:_delete+ flag.
      # TODO: eliminate; replace with %w[1 t true].include?(value.to_s.downcase)
      TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].to_set

      attr_reader :relationship
      attr_reader :assignment_guard
      attr_writer :assignment_factory

      def initialize(relationship, options)
        @relationship     = relationship
        @allow_destroy    = !!options.fetch(:allow_destroy, false)
        guard_factory     = options.fetch(:guard_factory) { Assignment::Guard }
        @assignment_guard = guard_factory.for(options.fetch(:reject_if, nil))
      end

      def allow_destroy?
        @allow_destroy
      end

      def accept(resource, attributes)
        sanitized_attributes = sanitize_attributes(resource, attributes)
        assignment = assignment_factory.for(self, resource)
        assignment.assign(sanitized_attributes)
        sanitized_attributes
      end

      def collection?
        relationship.max > 1
      end

      def resource?
        !collection?
      end

      def many_to_many?
        relationship.kind_of?(DataMapper::Associations::ManyToMany::Relationship)
      end

      # Extracts the primary key values necessary to retrieve or update a nested
      # model when using +accepts_nested_attributes_for+. Values are taken from
      # +assignee+ and the given attribute hash with the former having priority.
      # Values for properties in the primary key that are *not* included in the
      # foreign key must be specified in the attributes hash.
      #
      # @param [Hash{Symbol => Object}] attributes
      #   The attributes assigned to the nested attribute setter on the
      #   +model+.
      #
      # @return [Array]
      def extract_key(resource, attributes)
        relationship.extract_keys_for_nested_attributes(resource, attributes)
      end

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
      # @param [Hash] attributes
      #   The attributes to sanitize.
      #
      # @return [Hash]
      #   The sanitized attributes.
      def sanitize_attributes(resource, attributes)
        if resource.respond_to?(:sanitize_attributes)
          # TODO: issue deprecation warning for Resource#sanitize_attributes
          resource.sanitize_attributes(attributes)
        else
          attributes
        end
      end

      # Attribute hash keys that are excluded when creating a nested resource.
      # Excluded attributes include +:_delete+, a special value used to mark a
      # resource for destruction.
      #
      # @return [Array<Symbol>] Excluded attribute names.
      def uncreatable_keys(resource)
        if resource.respond_to?(:uncreatable_keys)
          # TODO: deprecation warning about Resource#uncreatable_keys
          resource.uncreatable_keys
        else
          [delete_key]
        end
      end

      # Attribute hash keys that are excluded when updating a nested resource.
      # Excluded attributes include the model key and :_delete, a special value
      # used to mark a resource for destruction.
      #
      # @return [Array<Symbol>] Excluded attribute names.
      def unupdatable_keys(resource)
        if resource.respond_to?(:unupdatable_keys)
          # TODO: deprecation warning about Resource#unupdatable_keys
          resource.unupdatable_keys
        else
          resource.model.key.map { |property| property.name } << delete_key
        end
      end

      def delete_key
        :_delete
      end

      # Determines whether the given attributes hash contains a truthy :_delete key.
      #
      # @param [Hash{Symbol => Object}] attributes
      #   The attributes to test.
      #
      # @return [Boolean]
      #   +true+ if attributes contains a truthy :_delete key.
      #
      # @see TRUE_VALUES
      def has_delete_flag?(attributes)
        value = attributes[delete_key]
        if value.is_a?(String) && value !~ /\S/
          nil
        else
          TRUE_VALUES.include?(value)
        end
      end

      # Determines if a new record should be built with the given attributes.
      # Rejects a new record if {#has_delete_flag?} returns +true+ for the given
      # attributes, or if a +:reject_if+ guard exists for the passed relationship
      # that evaluates to +true+.
      #
      # @param [Hash{Symbol => Object}] attributes
      #   The attributes to test with {#has_delete_flag?}.
      #
      # @return [Boolean]
      #   +true+ if the given attributes will be rejected.
      def reject_new_record?(resource, attributes)
        # if relationship guard is nil, nothing will be rejected
        assignment_guard.active? &&
          (has_delete_flag?(attributes) ||
          assignment_guard.reject?(resource, attributes))
      end

      def assignment_factory
        @assignment_factory || Assignment
      end

    end # class Acceptor
  end # module NestedAttributes
end # module DataMapper
