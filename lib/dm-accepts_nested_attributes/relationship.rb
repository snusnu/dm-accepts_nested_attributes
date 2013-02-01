module DataMapper
  module NestedAttributes

    # Extensions for {DataMapper::Associations::Relationship}.
    module Relationship
      # Extracts the primary key values necessary to retrieve or update a nested
      # model when using {Model#accepts_nested_attributes_for}. Values are taken from
      # the specified model and attribute hash with the former having priority.
      # Values for properties in the primary key that are *not* included in the
      # foreign key must be specified in the attributes hash.
      #
      # @param [DataMapper::Resource] resource
      #   The resource that accepts nested attributes.
      #
      # @param [Hash] attributes
      #   The attributes assigned to the nested attribute setter on the
      #   +model+.
      #
      # @return [Array, NilClass]
      #   Array if valid key values are present, nil otherwise
      # 
      # @api private
      def extract_keys_for_nested_attributes(model, attributes)
        target_model_key = self.target_model.key
        target_key_array = self.target_key.to_a
        source_key_array = self.source_key.to_a

        key_values = target_model_key.to_enum(:each_with_index).map do |key, idx|
          if source_idx = target_key_array.index(key)
            model[source_key_array.at(source_idx).name]
          else
            attributes[key.name]
          end
        end
        key_values = target_model_key.typecast(key_values)

        verify_key_values_for_nested_attributes(key_values)
      end

      # @api private
      def verify_key_values_for_nested_attributes(key_values)
        invalid = self.target_model.key.zip(key_values).any? do |property, value|
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
      def extract_keys_for_nested_attributes(model, attributes)
        key_values = self.child_key.map do |key|
          attributes[key.name]
        end

        verify_key_values_for_nested_attributes(key_values)
      end
    end

  end
end
