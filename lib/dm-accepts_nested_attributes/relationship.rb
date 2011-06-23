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
      # @param model [DataMapper::Model]
      #   The model that accepts nested attributes.
      #
      # @param attributes [Hash]
      #   The attributes assigned to the nested attribute setter on the
      #   +model+.
      #
      # @return [Array]
      def extract_keys_for_nested_attributes(resource, attributes)
        target_model_key = self.target_model.key
        target_key_array = self.target_key.to_a
        source_key_array = self.source_key.to_a

        keys = target_model_key.to_enum(:each_with_index).map do |key, idx|
          if source_idx = target_key_array.index(key)
            resource[source_key_array.at(source_idx).name]
          else
            attributes[key.name]
          end
        end

        keys.any? { |key| DataMapper::Ext.blank?(key) } ? nil : keys
      end
    end

    # Extensions for {DataMapper::Associations::ManyToMany::Relationship}.
    module ManyToMany
      def extract_keys_for_nested_attributes(resource, attributes)
        keys = self.child_key.map do |key|
          attributes[key.name]
        end

        keys.any? { |key| DataMapper::Ext.blank?(key) } ? nil : keys
      end
    end

  end
end
