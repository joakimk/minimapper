require "active_model"

module Minimapper
  module Entity
    module Validation
      def self.included(klass)
        klass.class_eval do
          extend  ActiveModel::Naming
          include ActiveModel::Validations

          # Must be added after ActiveModel::Validations so our
          # validations can call ActiveModel's with `super`.
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
    end
  end
end
