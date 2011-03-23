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
      def extract_keys_for_nested_attributes(model, attributes)
        raise NotImplementedError, "extract_keys must be overridden in a derived class"
      end
    end

    # Extensions for {DataMapper::Associations::ManyToMany::Relationship}.
    module ManyToMany
      def extract_keys_for_nested_attributes(model, attributes)
        keys = self.child_key.map do |key|
          attributes[key.name]
        end

        keys.any? { |key| DataMapper::Ext.blank?(key) } ? nil : keys
      end
    end

    # Extensions for {DataMapper::Associations::OneToMany::Relationship}.
    module OneToMany
      def extract_keys_for_nested_attributes(model, attributes)
        keys = self.child_model.key.to_enum(:each_with_index).map do |key, idx|
          if parent_idx = self.child_key.to_a.index(key)
            model[self.parent_key.to_a.at(parent_idx).name]
          else
            attributes[key.name]
          end
        end

        keys.any? { |key| DataMapper::Ext.blank?(key) } ? nil : keys
      end
    end

    # Extensions for {DataMapper::Associations::ManyToOne::Relationship}.
    module ManyToOne
      def extract_keys_for_nested_attributes(model, attributes)
        keys = self.parent_model.key.to_enum(:each_with_index).map do |key, idx|
          if child_idx = self.parent_key.to_a.index(key)
            model[self.child_key.to_a.at(child_idx).name]
          else
            attributes[key.name]
          end
        end

        keys.any? { |key| DataMapper::Ext.blank?(key) } ? nil : keys
      end
    end

    # Extensions for {DataMapper::Associations::OneToOne::Relationship}.
    module OneToOne
      def extract_keys_for_nested_attributes(model, attributes)
        keys = self.child_model.key.to_enum(:each_with_index).map do |key, idx|
          if parent_idx = self.child_key.to_a.index(key)
            model[self.parent_key.to_a.at(parent_idx).name]
          else
            attributes[key.name]
          end
        end

        keys.any? { |key| DataMapper::Ext.blank?(key) } ? nil : keys
      end
    end

  end
end
