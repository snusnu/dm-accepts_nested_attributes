module DataMapper
  module NestedAttributes
    ##
    # Extensions and customizations for a {DataMapper::Resource}
    # that are needed if the {DataMapper::Resource} wants to
    # accept nested attributes for any given relationship.
    # Basically, this module provides functionality that allows
    # either assignment or marking for destruction of related parent
    # and child associations, based on the given attributes and what
    # kind of relationship should be altered.
    module Resource
      # TODO: Why doesn't this work?
      #   because current implementation always calls #remove_destroyables,
      #   even if save failed... Is that desirable?
      # def self.included(model)
      #   model.after :save, :remove_destroyables
      # end

      ##
      # Saves the resource and destroys nested resources marked for destruction.
      def save(*)
        saved = super
        remove_destroyables
        saved
      end

      private

      def destroyables
        @destroyables ||= []
      end

      def remove_destroyables
        destroyables.each { |r| r.destroy if r.saved? }
        @destroyables.clear
      end

    end

  end
end
