require 'minimapper/entity/convert'

module Minimapper
  module Entity
    module Attributes
      def attributes(*list)
        list.each do |attribute|
          type = nil

          if attribute.is_a?(Array)
            attribute, type = attribute
          end

          define_method(attribute) do
            instance_variable_get("@#{attribute}")
          end

          define_method("#{attribute}=") do |value|
            value = Convert.new(value).to(type)
            instance_variable_set("@#{attribute}", value)
            attributes[attribute] = value
          end
        end
      end
    end
  end
end
