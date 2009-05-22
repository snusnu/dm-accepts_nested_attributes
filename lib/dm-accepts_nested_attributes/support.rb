module DataMapper
  module Resource

    private
    
    # Returns array of parent relationships for which this resource is child and is loaded
    #
    # @return [Array<DataMapper::Associations::ManyToOne::Relationship>]
    #   array of parent relationships for which this resource is child and is loaded
    #
    # @api private
    def parent_associations
      parent_associations = []

      relationships.each_value do |r|
        if r.kind_of?(Associations::ManyToOne::Relationship) && r.loaded?(self) && association = r.get!(self)
          parent_associations << association
        end
      end

      parent_associations.freeze
    end
    
  end
end
