# The core entity API required by minimapper. If your entity class implements
# this API, it should work with the mapper.

# IMPORTANT: This module should only implement the minimal interface needed
# to talk to the data mapper. If a method isn't used by the mapper it should
# not be in this file.

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

      def persisted?
        @entity_is_persisted
      end

      def mark_as_persisted
        @entity_is_persisted = true
      end

      def mark_as_not_persisted
        @entity_is_persisted = false
      end

      private

      def symbolize_keys(hash)
        hash.inject({}) { |h, (k, v)| h.merge!(k.to_sym => v) }
      end
    end
  end
end
