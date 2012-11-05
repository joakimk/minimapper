# Look at minimapper/entity/core for the required API.
require 'informal'
require 'minimapper/entity/core'
require 'minimapper/entity/attributes'
require 'minimapper/entity/rails'

module Minimapper
  module Entity
    include Minimapper::Entity::Core

    def self.included(klass)
      klass.send(:include, Informal::Model)
      klass.send(:include, Minimapper::Entity::Rails)
      klass.send(:extend, Minimapper::Entity::Attributes)
      klass.attributes([ :id, :Integer ], [ :created_at, :DateTime ], [ :updated_at, :DateTime ])
    end
  end
end
