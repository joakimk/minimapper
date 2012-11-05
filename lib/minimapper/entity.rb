# Minimapper does not require you to use this entity base class. It requires a
# few methods to be present, like valid?, attributes, attributes=.
#
# I plan to add shared examples that cover the API which minimapper depends upon.
#
# This class also does some things needed for it to work well with rails.
require 'informal'
require 'minimapper/entity/convert'

module Minimapper
  module Entity
    module ClassMethods
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

    module InstanceMethods
      def to_param
        id
      end

      def persisted?
        id
      end

      def attributes
        @attributes ||= {}
      end
    end

    def self.included(klass)
      klass.send(:include, Informal::Model)
      klass.send(:include, InstanceMethods)
      klass.send(:extend, ClassMethods)
      klass.attributes [ :id, :Integer ], [ :created_at, :DateTime ], [ :updated_at, :DateTime ]
    end
  end
end
