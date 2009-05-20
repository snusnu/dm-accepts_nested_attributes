module DataMapper
  module Associations
    
    module ManyToOne
      
      class Proxy
        
        def save
          
          return false if @parent.nil?
          
          # original dm-core-0.9.11 code:
          # return true unless parent.new_record?
          
          # and the backwards compatible extension to it (allows update of belongs_to model)
          if !parent.new? && !@relationship.child_model.autosave_associations.key?(@relationship.name)
            return true
          end

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