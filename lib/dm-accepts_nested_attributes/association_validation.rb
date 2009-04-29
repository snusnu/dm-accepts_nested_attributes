module DataMapper
  module NestedAttributes

    module AssociationValidation
      
      def save_child_associations(saved, context)
        return super if context.nil? # preserve save! behavior
        child_associations.each do |a|
          if a.respond_to?(:valid?)
            a.errors.each { |e| self.errors.add(:general, e) } unless a.valid?(context)
          else
            self.errors.add(:general, "child association is missing")
          end
          saved |= a.save
        end
        saved
      end

      def save_self
        self.valid? && super
      end

      def save_parent_associations(saved, context)
        parent_associations.each do |a|
          if a.respond_to?(:each) 
            a.each do |r|
              r.errors.each { |e| self.errors.add(:general, e) } unless r.valid?(context)
            end
          else                  
            a.errors.each { |e| self.errors.add(:general, e) } unless a.valid?(context)
          end
          saved |= a.save
        end
        saved
      end

      # everything works the same if this method isn't overwritten with a no-op
      # however, i suspect that this is the case because the registered before(:save) hook
      # somehow gets lost when overwriting Resource#save here in this module.
      # I'll leave it in for now, to make the purpose clear
      
      def check_validations(context = :default)
        true # no-op, validations are checked inside #save
      end

    end
    
  end
end