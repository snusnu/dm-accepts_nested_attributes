module DataMapper
  module NestedAttributes
    
    module Model
    
      def accepts_nested_attributes_for(association_name, options = {})
      
        assert_kind_of 'association_name', association_name, Symbol, String
        assert_kind_of 'options',          options,          Hash
        
        # by default, nested attributes can't be destroyed
        options = { :allow_destroy => false }.update(options)

        unless relationships[association_name]
          raise(ArgumentError, "Relationship #{name.inspect} does not exist in \#{model}")
        end
        
        unless options.all? { |k,v| [ :allow_destroy, :reject_if ].include?(k) }
          raise ArgumentError, 'options must be one of :allow_destroy or :reject_if'
        end

        # should be safe to go from here
      
        include ::DataMapper::NestedAttributes::Resource
      
        if ::DataMapper.const_defined?('Validate')

          require Pathname(__FILE__).dirname.expand_path + 'association_validation'

          include AssociationValidation

        end
      
        autosave_associations[association_name] = options
      
        type = nr_of_possible_child_instances(association_name) > 1 ? :collection : :one_to_one
      
        class_eval %{
        
          def save(context = :default)
            saved = false
            transaction { |t| t.rollback unless saved = super }
            saved
          end
        
          def #{association_name}_attributes
            @#{association_name}_attributes
          end
        
          def #{association_name}_attributes=(attributes)
            attributes = sanitize_nested_attributes(attributes)
            @#{association_name}_attributes = attributes
            assign_nested_attributes_for_#{type}_association(:#{association_name}, attributes, #{options[:allow_destroy]})
          end

        }, __FILE__, __LINE__ + 1
      
      end
    
    
      def autosave_associations
        @autosave_associations ||= {}
      end
    
      def reject_new_nested_attributes_proc_for(association_name)
        autosave_associations[association_name] ? autosave_associations[association_name][:reject_if] : nil
      end
    
    
      # utility methods

      def association_for_name(name)
        unless association = self.relationships[name]
          raise(ArgumentError, "Relationship #{name.inspect} does not exist in \#{model}")
        end
        association
      end
    
      def nr_of_possible_child_instances(relationship_name)
        association_for_name(relationship_name).max
      end

      def associated_model_for_name(association_name)
        association_for_name(association_name).target_model
      end
  
    end
    
  end
end
