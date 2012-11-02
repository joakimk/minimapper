require 'active_support/core_ext'

module Minimapper
  class Entity
    class Convert
      def initialize(value)
        @value = value
      end

      def to(type)
        return if value.blank?
        return value unless value.is_a?(String)

        case type.to_s
        when "Integer"
          to_integer
        when "DateTime"
          to_date_time
        else
          value
        end
      end

      private

      def to_integer
        if value =~ /[0-9]/
          value.to_i
        else
          nil
        end
      end

      def to_date_time
        DateTime.parse(value) rescue nil
      end

      attr_reader :value
    end
  end
end
