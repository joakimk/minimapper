# The core entity API required by minimapper. If your entity
# class implements this API, it should work with the data mappers.

module Minimapper
  module Entity
    module Core
      attr_accessor :id

      def attributes
        @attributes ||= {}
      end

      def attributes=(new_attributes)
        @attributes = attributes.merge(symbolize_keys(new_attributes))
      end

      def valid?
        mapper_errors.empty?
      end

      def mapper_errors
        @mapper_errors ||= []
      end

      def mapper_errors=(list)
        @mapper_errors = list
      end

      private

      def symbolize_keys(hash)
        hash.inject({}) { |h, (k, v)| h.merge!(k.to_sym => v) }
      end
    end
  end
end
