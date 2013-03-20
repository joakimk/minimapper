require 'minimapper/entity/convert'

module Minimapper
  module Entity
    module Attributes
      def attributes(*list)
        columns = add_columns(list)
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
        define_method(column.name) do
          attributes[column.name]
        end
      end

      def define_writer(column)
        define_method("#{column.name}=") do |value|
          attributes[column.name] = Convert.new(value).to(column.type)
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
