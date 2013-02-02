module DataMapper
  module NestedAttributes
    class Updater
      attr_reader :assignee
      attr_reader :configuration

      def initialize(assignee, configuration)
        @assignee      = assignee
        @configuration = configuration
      end

      # Updates a record with the +attributes+ or marks it for destruction if
      # the +:allow_destroy+ option is +true+ and {#delete_flagged?} returns
      # +true+.
      #
      # @param [DataMapper::Resource] resource
      #   The resource to be updated or destroyed
      #
      # @param [Hash{Symbol => Object}] attributes
      #   The attributes to assign to the relationship's target end.
      #   All attributes except {#unupdatable_keys} will be assigned.
      #
      # @return [void]
      def update(resource, attributes)
        if mark_as_destroyable?(attributes)
          mark_as_destroyable(resource)
        else
          update_attributes(resource, attributes)
        end
      end

      private

      def update_attributes(resource, attributes)
        assert_nested_update_clean_only(resource)
        resource.attributes = updatable_attributes(resource, attributes)
        # TODO: do we really want to call +resource#save+ here?
        #   after all, resource is set via a relationship on assignee;
        #   +resource+ will receive a #save call via +assignee#save+
        resource.save
      end

      def mark_as_destroyable(resource)
        destroyables << resource
      end

      def updatable_attributes(resource, attributes)
        unupdatable_keys = configuration.unupdatable_keys(resource)
        DataMapper::Ext::Hash.except(attributes, *unupdatable_keys)
      end

      def destroyables
        assignee.__send__(:destroyables)
      end

      # Raises an exception if the specified resource is dirty or has dirty
      # children.
      #
      # @param [DataMapper::Resource] resource
      #   The resource to check.
      #
      # @return [void]
      #
      # @raise [UpdateConflictError]
      #   If the resource is dirty.
      #
      # @api private
      def assert_nested_update_clean_only(resource)
        if resource.send(:dirty_self?) || resource.send(:dirty_children?)
          new_or_dirty = resource.new? ? 'new' : 'dirty'
          raise UpdateConflictError, "#{resource.model}#update cannot be called on a #{new_or_dirty} nested resource"
        end
      end

      def mark_as_destroyable?(attributes)
        configuration.allow_destroy? && configuration.delete_flagged?(attributes)
      end

      class ManyToMany < Updater
        def mark_as_destroyable(resource)
          intermediaries_to(resource).each do |intermediary|
            destroyables << intermediary
          end

          super
        end

        def intermediaries_to(resource)
          configuration.intermediaries_between(assignee, resource)
        end

      end # class ManyToMany

    end # class Updater
  end # module NestedAttributes
end # module DataMapper

