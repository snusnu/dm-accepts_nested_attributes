module DataMapper
  
  module AutosaveAssociation
    
    # debugging helper
    # TODO remove before release
    def print_call_stack(from = 2, to = nil, html = false)  
      (from..(to ? to : caller.length)).each do |idx| 
        p "[#{idx}]: #{caller[idx]}#{html ? '<br />' : ''}"
      end
    end
  
    # debugging helper (textmate rspec bundle)
    # TODO remove before release
    ESCAPE_TABLE = { '&'=>'&amp;', '<'=>'&lt;', '>'=>'&gt;', '"'=>'&quot;', "'"=>'&#039;', }
    def h(value)
      value.to_s.gsub(/[&<>"]/) {|s| ESCAPE_TABLE[s] }
    end
    
    def save(context = :default)
      
      saved = super
      
      if saved
        
        self.class.autosave_associations.each_pair do |association_name, options|
          
          if association = associated_instance_get(association_name) # && association.loaded?
            if association.is_a?(Array)
              # puts "association #{h(association.inspect)} is an Array<br />"
              association.each do |child|
                # puts "child = #{h(child.inspect)}<br />"
                # puts "marked_for_destruction? = #{child.marked_for_destruction?.inspect}<br />"
                child.marked_for_destruction? ? child.destroy : child.save #(context)
              end
            else
              
              # TODO once no debug output is needed, this is what we want to do
              # association.marked_for_destruction? ? association.destroy : association.save
              
              action = association.marked_for_destruction? ? :destroy : :save
              
              # puts "association = #{h(association.inspect)}<br />"
              # puts "marked_for_destruction? = #{association.marked_for_destruction?.inspect}<br />"
              # puts "association.attributes = #{h(association.attributes.inspect)}<br />"
              result = if association.marked_for_destruction?
                # puts("destroying #{association_name.inspect} ...<br />")
                association.destroy
              else
                # puts("updating #{association_name.inspect}... <br />")
                
                # print_call_stack(2, 10,true)
                
                association.save #(context)
              end
              # puts "association after action: #{h(association.inspect)}<br />"
              # association.reload
              # puts "association reloaded after action: #{h(association.inspect)}<br />"
              # puts "#{action} = #{result.inspect}<br />"
              result
              
            end
          else
            # puts "associated_instance_get(#{association_name.inspect}) returned #{h(association.inspect)}<br />"
          end
          
        end
      end
      saved
    end
    
    # Reloads the attributes of the object as usual and removes a mark for destruction.
    def reload
      @marked_for_destruction = false
      super
    end
    
    # if DataMapper.const_defined?('Validations')
    # 
    #   def valid?
    #     if super
    #       self.class.reflect_on_all_autosave_associations.all? do |reflection|
    #         if (association = association_instance_get(reflection.name)) && association.loaded?
    #           if association.is_a?(Array)
    #             association.proxy_target.all? { |child| autosave_association_valid?(reflection, child) }
    #           else
    #             autosave_association_valid?(reflection, association)
    #           end
    #         else
    #           true # association not loaded yet, so it should be valid
    #         end
    #       end
    #     else
    #       false # self was not valid
    #     end
    #   end
    #   
    #   # Returns whether or not the association is valid and applies any errors to the parent, <tt>self</tt>, if it wasn't.
    #   def autosave_association_valid?(reflection, association)
    #     returning(association.valid?) do |valid|
    #       association.errors.each do |attribute, message|
    #         errors.add "#{reflection.name}_#{attribute}", message
    #       end unless valid
    #     end
    #   end
    # 
    # end
    
    def marked_for_destruction?
      @marked_for_destruction
    end
    
    def mark_for_destruction
      @marked_for_destruction = true
    end
    
  end
  
end