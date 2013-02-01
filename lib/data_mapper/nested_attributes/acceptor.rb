require 'data_mapper/nested_attributes/assignment'
require 'data_mapper/nested_attributes/assignment/guard'
require 'data_mapper/nested_attributes/key_values_extractor'
require 'data_mapper/nested_attributes/updater'

module DataMapper
  module NestedAttributes
    class Acceptor
      # Truthy values for the +:_delete+ flag.
      # TODO: eliminate; replace with %w[1 t true].include?(value.to_s.downcase)
      TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].to_set

      def self.for(relationship, options)
        if relationship.kind_of?(Associations::ManyToMany::Relationship)
          Acceptor::ManyToMany.new(relationship, options)
        else
          Acceptor.new(relationship, options)
        end
      end

      attr_reader :relationship
      attr_reader :assignment_guard
      attr_reader :delete_key
      attr_writer :assignment_factory

      def initialize(relationship, options)
        @relationship     = relationship
        @allow_destroy    = !!options.fetch(:allow_destroy, false)
        guard_factory     = options.fetch(:guard_factory) { Assignment::Guard }
        @assignment_guard = guard_factory.for(options.fetch(:reject_if, nil))
        @delete_key       = options.fetch(:delete_key, NestedAttributes.delete_key).to_sym
      end

      def allow_destroy?
        @allow_destroy
      end

      def accept(resource, attributes)
        sanitized_attributes = sanitize_attributes(resource, attributes)
        assignment_for(resource).assign(sanitized_attributes)
        sanitized_attributes
      end

      def collection?
        relationship.max > 1
      end

      def resource?
        !collection?
      end

      def assignment_for(resource)
        assignment_factory.for(resource, self)
      end

      def assignment_factory
        @assignment_factory || Assignment
      end

      def key_values_extractor_for(resource)
        key_values_extractor_factory.new(relationship, resource)
      end

      def key_values_extractor_factory
        KeyValuesExtractor
      end

      def updater_for(resource)
        updater_factory.new(resource, self)
      end

      def updater_factory
        Updater
      end

      def get_associated(resource)
        relationship.get(resource)
      end

      def set_associated(resource, associated)
        relationship.set(resource, associated)
      end

      def new_target_model_instance
        relationship.target_model.new
      end

      def intermediaries_between(source, target)
        intermediary_collection(source).all(relationship.via => target)
      end

      def intermediary_collection(source)
        relationship.through.get(source)
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
      # @param [DataMapper::Resource] resource
      #   Resource for which valid creatable attribute keys will be returned
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
      # @param [DataMapper::Resource] resource
      #   Resource for which valid updatable attribute keys will be returned
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

      # Determines whether the given attributes hash contains a truthy :_delete key.
      #
      # @param [Hash{Symbol => Object}] attributes
      #   The attributes to test.
      #
      # @return [Boolean]
      #   +true+ if attributes contains a truthy :_delete key.
      #
      # @see TRUE_VALUES
      def delete_flagged?(attributes)
        value = attributes[delete_key]
        if value.is_a?(String) && value !~ /\S/
          nil
        else
          TRUE_VALUES.include?(value)
        end
      end

      # Determines if a new record should be built with the given attributes.
      # Rejects a new record if {#delete_flagged?} returns +true+ for the given
      # attributes, or if a +:reject_if+ guard exists for the passed relationship
      # that evaluates to +true+.
      #
      # @param [Hash{Symbol => Object}] attributes
      #   The attributes to test with {#delete_flagged?}.
      #
      # @return [Boolean]
      #   +true+ if the given attributes will be rejected.
      def accept_new_resource?(resource, attributes)
        !assignment_guard.active? ||
          !delete_flagged?(attributes) &&
          assignment_guard.accept?(resource, attributes)
      end


      class ManyToMany < Acceptor
        def key_values_extractor_factory
          KeyValuesExtractor::ManyToMany
        end

        def updater_factory
          Updater::ManyToMany
        end
      end # class ManyToMany

    end # class Acceptor
  end # module NestedAttributes
end # module DataMapper
