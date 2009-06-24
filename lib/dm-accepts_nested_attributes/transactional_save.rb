module DataMapper
  module NestedAttributes
    
    module TransactionalSave
      
      def save(*)
        saved = false
        transaction { |t| t.rollback unless saved = super }
        saved
      end
      
    end
    
  end
end