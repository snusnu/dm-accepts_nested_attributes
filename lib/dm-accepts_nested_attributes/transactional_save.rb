module DataMapper
  module NestedAttributes

    module TransactionalSave

      ##
      # Overrides @see DataMapper::Resource#save to perform inside a transaction.
      # The current implementation simply wraps the saving of the complete object tree
      # inside a transaction and rolls back in case any exceptions are raised,
      # or any of the calls to
      #
      # @see DataMapper::Resource#save
      #
      # @return [Boolean]
      #   true if all related resources were saved properly
      #
      def save
        transaction { |t| super || t.rollback && false }
      end

    end

  end
end
