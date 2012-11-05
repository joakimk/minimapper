# Look at minimapper/entity/core for the required API.
require 'minimapper/entity/core'
require 'minimapper/entity/attributes'
require 'minimapper/entity/rails'

module Minimapper
  module Entity
    include Minimapper::Entity::Core

    def initialize(attributes = {})
      self.attributes = attributes
    end

    def attributes=(new_attributes)
      super(new_attributes)
      new_attributes.each_pair { |name, value| self.send("#{name}=", value) }
    end

    def self.included(klass)
      klass.send(:include, Minimapper::Entity::Rails)
      klass.send(:extend, Minimapper::Entity::Attributes)
      klass.attributes([ :id, :Integer ], [ :created_at, :DateTime ], [ :updated_at, :DateTime ])
    end
  end
end
