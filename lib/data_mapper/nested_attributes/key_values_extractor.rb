require 'forwardable'

module DataMapper
  module NestedAttributes
    class KeyValuesExtractor
      extend Forwardable

      attr_reader :relationship
      attr_reader :resource

      def_delegators :relationship, :target_model, :target_key, :source_key
      def_delegator  :target_model, :key, :target_model_key

      alias_method :casting_key, :target_model_key

      def initialize(relationship, resource)
        @relationship = relationship
        @resource     = resource
      end

      # Extracts the primary key values necessary to retrieve or update a nested
      # resource when using {Model#accepts_nested_attributes_for}. Values are taken from
      # the specified resource and attribute hash with the former having priority.
      # Values for properties in the primary key that are *not* included in the
      # foreign key must be specified in the attributes hash.
      #
      # @param [Hash] attributes
      #   The attributes assigned to the nested attribute setter on the
      #   +resource+.
      #
      # @return [Array, NilClass]
      #   Array if valid key values are present, nil otherwise
      #
      # @api private
      def extract(attributes)
        raw_key_values = extract_raw_key_values(attributes)
        key_values     = casting_key.typecast(raw_key_values)

        filter_invalid_key_values(key_values)
      end

      private

      def extract_raw_key_values(attributes)
        target_model_key.map do |target_property|
          if source_property = target_key_to_source_key_map[target_property]
            resource[source_property.name]
          else
            attributes[target_property.name]
          end
        end
      end

      def target_key_to_source_key_map
        @target_key_to_source_key_map ||=
          Hash[target_key.to_a.zip(source_key.to_a)]
      end

      # @api private
      def filter_invalid_key_values(key_values)
        key_properties_and_values = target_model_key.zip(key_values)

        valid = key_properties_and_values.all? do |property, value|
          valid_value_for_property?(property, value)
        end

        key_values if valid
      end

      # @return [Boolean]
      #   whether +value+ is valid for +property+
      #
      # @api private
      #
      # TODO: move this into Property?
      def valid_value_for_property?(property, value)
        case
        when property.allow_nil?            then true
        when property.allow_blank?          then !value.nil?
        when Property::Boolean === property then true
        else
          !DataMapper::Ext.blank?(value)
        end
      end

      class ManyToMany < KeyValuesExtractor
        private

        def_delegators :relationship, :child_key

        alias_method :casting_key, :child_key

        def extract_raw_key_values(attributes)
          attributes.values_at(*child_key.map { |property| property.name })
        end

      end # class ManyToMany

    end # class KeyValuesExtractor
  end # module NestedAttributes
end # module DataMapper
