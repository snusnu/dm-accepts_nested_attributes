module DataMapper
  module NestedAttributes

    module AssociationValidation
      
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
          if parent.save(*args)
            relationship.set(self, parent) # set the FK values
          end
        end
      end

    end
    
    module ErrorCollection
      
      # collect errors on parent associations
      def before_save_parent_association(association, context)
        if association.respond_to?(:each) 
          association.each do |r|
            unless r.valid?(context)
              r.errors.each { |e| self.errors.add(:general, e) }
            end
          end
        else
          unless association.valid?(context)
            association.errors.each { |e| self.errors.add(:general, e) }
          end
        end
      end

      # collect errors on child associations
      def before_save_child_association(association, context)
        if association.respond_to?(:valid?)
          unless association.valid?(context)
            association.errors.each { |e| self.errors.add(:general, e) }
          end
        else
          self.errors.add(:general, "child association is missing")
        end
      end
      
    end
    
  end
end