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
          parent = relationship.get!(self)
          if parent.save_self(*args)
            relationship.set(self, parent)
          end
        end
      rescue DataObjects::IntegrityError => e
        # TODO i don't know if that's the best way or simply a workaround, but
        # respect save's protocol to return false in case something went wrong
        DataMapper.logger.info e
        false
      end

    end
    
  end
end