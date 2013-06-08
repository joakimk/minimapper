# Include this in your entity classes for
# Ruby on Rails conveniences, like being
# able to use them in forms.

module Minimapper
  module Entity
    module Rails
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
