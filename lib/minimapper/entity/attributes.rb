module Minimapper
  module Entity
    module Attributes
      class InvalidType < StandardError; end

      def self.included(klass)
        klass.extend ClassMethods
      end

      def initialize(attributes = {})
        self.attributes = attributes
      end

      def attributes=(new_attributes)
        super(new_attributes)
        new_attributes.each_pair { |name, value| self.send("#{name}=", value) }
      end

      def normalize_attribute_value(value, type)
        value = DateTime.parse(value.to_s) if value.is_a?(Time)

        if valid_type?(value, type)
          value
        else
          raise InvalidType, "Expected '#{value}' to be a #{type}, but it's a #{value.class}"
        end
      end

      def valid_type?(value, type)
        type.nil? ||
          value.nil? ||
          value.is_a?(type)
      end

      module ClassMethods
        def attributes(*list)
          columns = add_columns(list)

          # By adding instance methods via an included module,
          # they become overridable with "super".
          unless @minimapper_instance_method_container
            @minimapper_instance_method_container = Module.new
            include @minimapper_instance_method_container
          end

          columns.each do |column|
            define_reader(column)
            define_writer(column)
          end
        end

        def attribute(*opts)
          attributes [ *opts ]
        end

        # Compatibility with certain Rails plugins, like Traco.
        def column_names
          @entity_columns.map(&:name).map(&:to_s)
        end

        private

        def add_columns(list)
          @entity_columns ||= []
          @entity_columns |= list.map { |data| Column.new(data) }
        end

        def define_reader(column)
          @minimapper_instance_method_container.module_eval do
            define_method(column.name) do
              attributes[column.name]
            end
          end
        end

        def define_writer(column)
          @minimapper_instance_method_container.module_eval do
            define_method("#{column.name}=") do |value|
              attributes[column.name] = normalize_attribute_value(value, column.type)
            end
          end
        end

        class Column
          attr_reader :name, :type

          def initialize(data)
            if data.is_a?(Array)
              @name, @type = data
            else
              @name = data
            end
          end
        end
      end
    end
  end
end
