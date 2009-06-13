module DataMapper
  module NestedAttributes

    module Save
      
      def save(*args)
        if marked_for_destruction?
          destroy
        else
          save_parents(*args) && super
        end
      end
 
      def save_parents(*args)
        parent_relationships.all? do |relationship|
          parent = relationship.get(self)
          if parent.save(*args)
            relationship.set(self, parent)
          end
        end
      end

    end
    
  end
end