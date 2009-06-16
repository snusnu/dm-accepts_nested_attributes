module DataMapper
  module NestedAttributes

    module Save
      
      def save(*)
        marked_for_destruction? ? destroy : super
      end

    end
    
  end
end