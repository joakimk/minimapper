# Include this in your entity classes for
# Ruby on Rails conveniences, like being
# able to use them in forms.

module Minimapper
  module Entity
    module Rails
      def to_param
        id
      end

      # Implemented in core.
      def persisted?
        super
      end

      def new_record?
        !persisted?
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
