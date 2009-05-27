module DataMapper
  module NestedAttributes

    module Save
      
      extend DataMapper::Chainable
      
      chainable do
        def save(*args)
          save_parents(*args) && super
        end
      end
      
      def parent_relationships
        parent_relationships = []
 
        relationships.each_value do |relationship|
          next unless relationship.respond_to?(:resource_for) && relationship.loaded?(self)
          parent_relationships << relationship
        end
 
        parent_relationships
      end
 
      def save_parents(*args)
        parent_relationships.all? do |relationship|
          save_parent_relationship(relationship, *args)
        end
      end

      def save_parent_relationship(relationship, *args)
        parent = relationship.get(self)
        if parent.save(*args)
          relationship.set(self, parent) # set the FK values
        end
      end

    end
    
  end
end