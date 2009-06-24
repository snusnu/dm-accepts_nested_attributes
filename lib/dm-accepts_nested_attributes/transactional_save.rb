module DataMapper
  module NestedAttributes
    
    module TransactionalSave
      
      ##
      # Overrides @see DataMapper::Resource#save to perform inside a transaction.
      # The current implementation simply wraps the saving of the complete object tree
      # inside a transaction and rolls back in case any exceptions are raised,
      # or any of the calls to
      #
      # @see DataMapper::Resource#save returned false
      #
      # @return [true, false]
      #   true if all related resources were saved properly
      #
      def save(*)
        saved = false
        transaction { |t| t.rollback unless saved = super }
        saved
      end
      
    end
    
  end
end