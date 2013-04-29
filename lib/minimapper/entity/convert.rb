require 'minimapper/entity/convert/to_integer'
require 'minimapper/entity/convert/to_date_time'

module Minimapper
  module Entity
    class Convert
      def initialize(value)
        @value = value
      end

      def self.register_converter(type, converter)
        @@converters ||= {}
        @@converters[type] = converter
      end

      register_converter :integer,   ToInteger.new
      register_converter :date_time, ToDateTime.new

      def to(type)
        return nil   if     value != false && value.blank?
        return value unless value.is_a?(String)

        converter_for(type).convert(value)
      end

      private

      def converter_for(type)
        @@converters.fetch(type, NoOpConverter.new)
      end

      class NoOpConverter
        def convert(value)
          value
        end
      end

      attr_reader :value
    end
  end
end
