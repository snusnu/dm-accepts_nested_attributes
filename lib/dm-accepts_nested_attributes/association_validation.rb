module DataMapper
  module NestedAttributes

    module AssociationValidation

      # NOTE: 
      # overwriting Resource#save like this breaks the before(:save) hook stack
      # this hopefully is no problem, since the current implementation doesn't rely on
      # a before(:save) hook, but rather overwrites this hook with a no-op, and adds
      # the desired behavior via overwriting Resource#save directly. I'd really appreciate
      # any ideas for doing this differently, though. Anyways, I'm not really sure if this
      # is the right approach. I don't even know if it works with custom validations,
      # or maybe breaks other things. It's also really not well specced at all atm.
      # Use at your own risk :-)

      def save(context = :default)

        # -----------------------------------------------------------------
        #              ORIGINAL CODE from Resource#save
        # -----------------------------------------------------------------
        #
        # associations_saved = false
        # child_associations.each { |a| associations_saved |= a.save }
        # 
        # saved = new_record? ? create : update
        # 
        # if saved
        #   original_values.clear
        # end
        # 
        # parent_associations.each { |a| associations_saved |= a.save }
        # 
        # # We should return true if the model (or any of its associations)
        # # were saved.
        # (saved | associations_saved) == true
        #
        # -----------------------------------------------------------------

        return super if context.nil? # preserve save! behavior

        associations_saved = false

        child_associations.each do |a|
  
          if a.respond_to?(:valid?)
            a.errors.each { |e| self.errors.add(:general, e) } unless a.valid?(context)
          else
            self.errors.add(:general, "child association is missing")
          end
  
          associations_saved |= a.save
  
        end

        saved = self.valid? && (new_record? ? create : update)

        if saved
          original_values.clear
        end

        parent_associations.each do |a|
  
          if a.respond_to?(:each) 
            a.each do |r|
              r.errors.each { |e| self.errors.add(:general, e) } unless r.valid?(context)
            end
          else                  
            a.errors.each { |e| self.errors.add(:general, e) } unless a.valid?(context)
          end
  
          associations_saved |= a.save
  
        end

        (saved | associations_saved) == true

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