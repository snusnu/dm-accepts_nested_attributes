module DataMapper
  module NestedAttributes

    module Save
      
      def save(*args)
        puts "[DANA] Resource#save class = #{self.class.name}, id = #{self.id}, object_id = #{object_id}<br />"
        if marked_for_destruction?
          puts "[DANA] calling destroy"
          destroy
        else
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
          if parent.save(*args)
            relationship.set(self, parent)
          end
        end
      end

    end
    
  end
end