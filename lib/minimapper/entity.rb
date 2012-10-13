require 'informal'

module Minimapper
  class Entity
    include Informal::Model

    def self.attributes(*list)
      list.each do |attribute|
        define_method(attribute) do
          instance_variable_get("@#{attribute}")
        end

        define_method("#{attribute}=") do |value|
          instance_variable_set("@#{attribute}", value)
          @attributes[attribute] = value
        end
      end
    end

    def initialize(*opts)
      @attributes = {}
      super(*opts)
    end

    def to_param
      id
    end

    def persisted?
      id
    end

    attributes :id, :created_at, :updated_at

    attr_reader :attributes
  end
end
