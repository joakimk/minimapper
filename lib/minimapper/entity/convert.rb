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
        @@converters[type.to_s] = converter
      end

      def to(type)
        return nil if value.blank?
        return value unless value.is_a?(String)

        converter_for(type).convert(value)
      end

      register_converter Integer,  ToInteger.new
      register_converter DateTime, ToDateTime.new

      private

      def converter_for(type)
        @@converters.fetch(type.to_s, NoOpConverter.new)
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
