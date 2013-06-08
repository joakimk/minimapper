# Look at minimapper/entity/core for the required API.
require 'minimapper/entity/core'
require 'minimapper/entity/attributes'
require 'minimapper/entity/validation'
require 'minimapper/entity/rails'

module Minimapper
  module Entity
    include Minimapper::Entity::Core

    def ==(other)
      super || (
        other.instance_of?(self.class) &&
        self.id &&
        other.id == self.id
      )
    end

    def self.included(klass)
      klass.send(:include, Minimapper::Entity::Attributes)
      klass.send(:include, Minimapper::Entity::Validation)
      klass.send(:include, Minimapper::Entity::Rails)
      klass.attributes(
        [ :id, :integer ],
        [ :created_at, :date_time ],
        [ :updated_at, :date_time ]
      )
    end
  end
end
