module DataMapper
  module Associations
    
    module ManyToOne
      
      class Proxy
        
        def save
          
          return false if @parent.nil?
          
          # With this next line commented out, updating works !?!
          # Also, I ran specs for dm-core-0.9.11 with this line
          # commented out, and the only additional failures were
          # because some mocks(!) didn't receive a call to new_record?
          #
          # I don't know if this means that this line is useless,
          # or if there simply aren't enough (or wrong) specs in
          # 0.9.11
          #
          # I'll leave this to the experts :)
          
          
          # return true  unless parent.new_record?

          @relationship.with_repository(parent) do
            result = parent.marked_for_destruction? ? parent.destroy : parent.save
            @relationship.child_key.set(@child, @relationship.parent_key.get(parent)) if result
            result
          end
        end
        
      end
      
    end
    
    
    module OneToMany
    
      class Proxy
        
        private
        
        def save_resource(resource, parent = @parent)
          @relationship.with_repository(resource) do |r|
            if parent.nil? && resource.model.respond_to?(:many_to_many)
              resource.destroy
            else
              @relationship.attach_parent(resource, parent)
              resource.marked_for_destruction? ? resource.destroy : resource.save
            end
          end
        end
        
      end
      
    end
    
  end
end