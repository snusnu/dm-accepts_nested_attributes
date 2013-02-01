require 'dm-core'

require 'data_mapper/nested_attributes/version'

require 'data_mapper/nested_attributes/model'
require 'data_mapper/nested_attributes/resource'
require 'data_mapper/nested_attributes/acceptor'
require 'data_mapper/nested_attributes/assignment'
require 'data_mapper/nested_attributes/assignment/guard'
require 'data_mapper/nested_attributes/key_values_extractor'
require 'data_mapper/nested_attributes/updater'

module DataMapper
  module NestedAttributes

    # Set the name of the key that marks a record for deletion
    #
    # @param [Symbol] name
    #   the name of the key
    #
    # @return [Symbol]
    #
    # @api public
    def self.delete_key=(name)
      @name = name
    end

    # The name of the key that marks a record for deletion
    #
    # @return [Symbol]
    #
    # @api private
    def self.delete_key
      @name ||= :_delete
    end
  end # module NestedAttributes
end # module DataMapper

# Activate the plugin
DataMapper::Model.append_extensions(DataMapper::NestedAttributes::Model)
