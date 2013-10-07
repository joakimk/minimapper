require 'minimapper/entity/convert'

module Minimapper
  module Entity
    module FormConversions
      def normalize_attribute_value(value, type)
        value = Convert.new(value).to(type) if value
        super(value, type)
      end
    end
  end
end
