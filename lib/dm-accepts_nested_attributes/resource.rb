module DataMapper
  module Resource
  
    # basic extract method refactorings to work around a bug in extlib
    # see http://sick.snusnu.info/2009/04/29/extlibhook-breaks-if-hooked-method-is-redefined/
    # maybe they are worth considering even when the bug in extlib (hopefully) gets fixed
    
    def save(context = :default)
      
      associations_saved = false
      associations_saved = save_child_associations(associations_saved, context)
      
      saved = save_self
      
      if saved
        original_values.clear
      end
      
      associations_saved = save_parent_associations(associations_saved, context)
      
      # We should return true if the model (or any of its associations) were saved.
      (saved | associations_saved) == true
      
    end
    
    
    def save_child_associations(saved, context)
      child_associations.each { |a| saved |= a.save }
      saved
    end
    
    def save_self
      new_record? ? create : update
    end
    
    def save_parent_associations(saved, context)
      parent_associations.each { |a| saved |= a.save }
      saved
    end
    
  end
end