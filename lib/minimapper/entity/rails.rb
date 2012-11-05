require "active_model"

module Minimapper
  module Entity
    module Rails
      def self.included(klass)
        klass.class_eval do
          extend  ActiveModel::Naming
          include ActiveModel::Validations
        end
      end

      def to_param
        id
      end

      def persisted?
        id
      end

      def new_record?
        !id
      end

      def to_model
        self
      end

      def to_key
        persisted? ? [ id ] : nil
      end
    end
  end
end
