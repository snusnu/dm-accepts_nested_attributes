module DataMapper
  module NestedAttributes
    
    module TransactionalSave
      
      extend DataMapper::Chainable
      
      chainable do
        def save(*args)
          saved = false
          transaction { |t| t.rollback unless saved = super }
          saved
        end
      end
      
    end
    
  end
end