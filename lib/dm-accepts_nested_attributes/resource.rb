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
      # def self.included(model)
      #   model.after :save, :remove_destroyables
      # end

      # Can be used to remove ambiguities from the passed attributes.
      # Consider a situation with a belongs_to association where both a valid value
      # for the foreign_key attribute *and* nested_attributes for a new record are
      # present (i.e. item_type_id and item_type_attributes are present).
      # Also see http://is.gd/sz2d on the rails-core ml for a discussion on this.
      # The basic idea is, that there should be a well defined behavior for what
      # exactly happens when such a situation occurs. I'm currently in favor for
      # using the foreign_key if it is present, but this probably needs more thinking.
      # For now, this method basically is a no-op, but at least it provides a hook where
      # everyone can perform it's own sanitization by overwriting this method.
      #
      # @param [Hash] attributes
      #   The attributes to sanitize.
      #
      # @return [Hash]
      #   The sanitized attributes.
      def sanitize_nested_attributes(attributes)
        attributes # noop
      end

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
