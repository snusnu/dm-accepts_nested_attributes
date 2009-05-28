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
          parent = relationship.get(self)
          if parent.marked_for_destruction?
            parent.destroy
          else
            if parent.save(*args)
              relationship.set(self, parent)
            end
          end
        end
      end

    end
    
  end
end