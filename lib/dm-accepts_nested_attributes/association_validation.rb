module DataMapper
  module NestedAttributes

    module AssociationValidation
      
      def save(context = :default)
        unless save_parent_associations(context)
          return false
        end
        unless save_self(context)
          return false
        end
        save_child_associations(context)
      end

      private

      def save_parent_associations(context)
        parent_associations.all? do |a|
          before_save_parent_association(a, context)
          ret = a.save
          puts "save_parent_associations: save returned #{ret.inspect}, saved object = #{a.inspect}"
          ret
        end
      end

      def save_self(context)
        _save_self = lambda { new? ? _create : _update }
        if context.nil?
          _save_self.call
        else
          if self.valid?(context)
            _save_self.call
          else
            puts "save FAIL: save_self failed with errors = #{self.errors.inspect}" 
          end
        end
      end

      def save_child_associations(context)
        child_associations.all? do |a|
          before_save_child_association(a, context)
          ret = a.save
          puts "save_child_associations: save returned #{ret.inspect}, saved object = #{a.inspect}"
          ret
        end
      end

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