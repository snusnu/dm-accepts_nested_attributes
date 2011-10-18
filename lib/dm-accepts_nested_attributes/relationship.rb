module DataMapper
  module NestedAttributes

    # Extensions for {DataMapper::Associations::Relationship}.
    module Relationship
      # Extracts the primary key values necessary to retrieve or update a nested
      # resource when using {Model#accepts_nested_attributes_for}. Values are taken from
      # the specified resource and attribute hash with the former having priority.
      # Values for properties in the primary key that are *not* included in the
      # foreign key must be specified in the attributes hash.
      #
      # @param [DataMapper::Resource] resource
      #   The resource that accepts nested attributes.
      #
      # @param [Hash] attributes
      #   The attributes assigned to the nested attribute setter on the
      #   +resource+.
      #
      # @return [Array, NilClass]
      #   Array if valid key values are present, nil otherwise
      # 
      # @api private
      def extract_keys_for_nested_attributes(resource, attributes)
        raw_key_values = extract_target_primary_key_values(resource, attributes)
        key_values     = target_model.key.typecast(raw_key_values)

        verify_key_values_for_nested_attributes(key_values)
      end

      def extract_target_primary_key_values(resource, attributes)
        target_model.key.map do |target_property|
          if source_property = target_key_to_source_key_map[target_property]
            resource[source_property.name]
          else
            attributes[target_property.name]
          end
        end
      end

      def target_key_to_source_key_map
        @target_key_to_source_key_map ||= Hash[target_key.to_a.zip(source_key.to_a)]
      end

      # @api private
      def verify_key_values_for_nested_attributes(key_values)
        invalid = target_model.key.zip(key_values).any? do |property, value|
          verify_single_key_value_for_nested_attributes(property, value)
        end

        invalid ? nil : key_values
      end

      # @return [Boolean]
      #   whether +value+ is valid for +property+
      # 
      # @api private
      # 
      # TODO: move this into Property?
      def verify_single_key_value_for_nested_attributes(property, value)
        case
        when property.allow_nil?            then false
        when property.allow_blank?          then value.nil?
        when Property::Boolean === property then false
        else
          DataMapper::Ext.blank?(value)
        end
      end
    end

    # Extensions for {DataMapper::Associations::ManyToMany::Relationship}.
    module ManyToMany
      # @api private
      def extract_keys_for_nested_attributes(resource, attributes)
        child_key      = self.child_key
        raw_key_values = attributes.values_at(*child_key.map { |key| key.name })
        key_values     = child_key.typecast(raw_key_values)

        verify_key_values_for_nested_attributes(key_values)
      end
    end

  end
end
