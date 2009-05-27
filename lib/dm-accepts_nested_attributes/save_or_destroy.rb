module DataMapper
  module NestedAttributes
    
    module SaveOrDestroyResourceBehavior
      
      def save_parent_relationship(relationship, *args)
        parent = relationship.get(self)
        if parent.marked_for_destruction?
          parent.destroy
        else        
          relationship.set(self, parent) if parent.save(*args)
        end
      end
      
    end
    
  end
end