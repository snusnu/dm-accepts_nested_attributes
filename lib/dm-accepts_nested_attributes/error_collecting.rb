module DataMapper
  module NestedAttributes

    module ValidationErrorCollecting

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
