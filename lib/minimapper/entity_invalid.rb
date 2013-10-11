module Minimapper
  class EntityInvalid < StandardError
    def initialize(entity)
      @entity = entity
    end

    def message
      # As long as the mappers support Minimapper::Entity::Core, we can't expect .errors to exist. I'm thinking of removing core as I don't use it myself and don't know anyone who does.
      return super unless @entity.respond_to?(:errors)

      @entity.errors.full_messages.join(', ')
    end
  end
end
