# Include this in your entity models for
# Ruby on Rails conveniences, like being
# able to use them in forms.

require "active_model"

module Minimapper
  module Entity
    module Rails
      def self.included(klass)
        klass.class_eval do
          extend  ActiveModel::Naming
          include ActiveModel::Validations

          # Must be later than ActiveModel::Validations so
          # it can call it with super.
          include ValidationsWithMapperErrors
        end
      end

      module ValidationsWithMapperErrors
        def valid?
          super

          mapper_errors.each do |a, v|
            errors.add(a, v)
          end

          errors.empty?
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
