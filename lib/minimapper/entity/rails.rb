module Minimapper
  module Entity
    module Rails
      def to_param
        id
      end

      def persisted?
        id
      end
    end
  end
end
