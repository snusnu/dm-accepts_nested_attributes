module DataMapper
  module NestedAttributes

    module Save
      
      # TODO
      #
      # It looks likes this doesn't get called when saving
      # resources inside a OneToMany::Collection, which has
      # the effect that deleting via nested attribute accessors
      # doesn't work
      #
      def save(*args)
        if marked_for_destruction?
          destroy
        else
          # TODO
          # actually i only want to call super here
          # because from what I can see that happens
          # with what I do now, it essentially calls
          #
          # save_parents && save_parents && save_self && save_children
          #
          # However, if I do that, then
          #
          # p = Person.new
          # p.profile_attributes = { :nick => :snusnu }
          # p.save
          #
          # doesn't work anymore, but complains that it
          # can't assign profile.person (fk) can't be nil
          save_parents(*args) && super
        end
      end

      # TODO
      #
      # If I use the original dm-core code, then I get the following errors
      #
      # DataObjects::IntegrityError: Column 'name' cannot be null
      #
      # a detailed stacktrace can be found at: http://pastie.org/510932
      def save_parents(*args)
        parent_relationships.all? do |relationship|
          # TODO
          # original dm-core code calls
          # relationship.get!(self)
          parent = relationship.get!(self)
          # TODO
          # original dm-core code calls
          # parent.save_self
          if parent.save(*args)
            relationship.set(self, parent)
          end
        end
      end

    end
    
  end
end