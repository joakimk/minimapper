# Minimapper does not require you to use this entity base class. It requires a
# few methods to be present, like valid?, attributes, attributes=.
#
# I plan to convert this to a module and add shared examples that cover
# the API which minimapper depends upon.
#
# This class also does some things needed for it to work well with rails.
require 'informal'
require 'minimapper/entity/convert'

module Minimapper
  class Entity
    include Informal::Model

    def self.attributes(*list)
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

    attributes [ :id, Integer ], [ :created_at, DateTime ], [ :updated_at, DateTime ]

    attr_reader :attributes
  end
end
