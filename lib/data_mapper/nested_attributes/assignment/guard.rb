module DataMapper
  module NestedAttributes

    unless const_defined?(:InvalidOptions)
      class InvalidOptions < ArgumentError; end
    end

    class Assignment
      class Guard
        attr_reader :value

        def self.for(value)
          if value.is_a?(Symbol) || value.is_a?(String)
            Method.new(value)
          elsif value.respond_to?(:call)
            Proc.new(value)
          elsif value.nil?
            Inactive.new(value)
          else
            # never reached when called from inside the plugin
            message = "guard must be nil, a Symbol, a String, or respond_to?(:call)"
            raise InvalidOptions, message
          end
        end

        def initialize(value)
          @value = value
        end

        def accept?(resource, attributes)
          !reject?(resource, attributes)
        end

        def reject?(resource, attributes)
          raise NotImplementedError, "#{self.class}#reject? is not implemented"
        end

        def active?
          true
        end

        class Inactive < Guard
          def reject?(resource, attributes)
            false
          end

          def active?
            false
          end
        end

        class Method < Guard
          def reject?(resource, attributes)
            resource.send(value, attributes)
          end
        end

        class Proc < Guard
          def reject?(resource, attributes)
            value.call(attributes)
          end
        end
      end

    end # class Assignment
  end # module NestedAttributes
end # module DataMapper
