require 'minimapper/common'

module Minimapper
  class Memory
    def initialize
      @store = []
      @last_id = 0
    end

    # Create
    def create(entity)
      if entity.valid?
        entity.id = next_id
        store.push(entity.dup)
        last_id
      else
        false
      end
    end

    # Read
    def find(id)
      find_internal_safely(id).dup
    end

    # Find an entity by id
    #
    # Returns an entity when found, otherwise nil.
    #
    # @param [Integer, String] id the entity id to find
    # @return [Minimapper::Entity]
    # @return [nil]
    def find_by_id(id)
      entity = find_internal(id)
      entity && entity.dup
    end

    def all
      store.map { |entity| entity.dup }
    end

    # Get the first added entity
    #
    #  mapper.first
    #  # => #<User:...>
    #
    # @return (see #entity_class)
    def first
      store.first && store.first.dup
    end

    # Get the last added entity
    #
    #  mapper.last
    #  # => #<User:...>
    #
    # @return (see #entity_class)
    def last
      store.last && store.last.dup
    end

    # Return the total number of entities
    # @return [Integer]
    def count
      all.size
    end

    # @return an instance of the class set with self.entity_class=
    def entity_class
    end

    # Update
    def update(entity)
      if entity.valid?
        known_entity = find_internal_safely(entity.id)
        known_entity.attributes = entity.attributes
        true
      else
        false
      end
    end

    # Delete
    def delete(entity)
      delete_by_id(entity.id)
      entity.id = nil
    end

    def delete_by_id(id)
      entity = find_internal_safely(id)
      store.delete(entity)
    end

    def delete_all
      store.clear
    end

    private

    def find_internal_safely(id)
      find_internal(id) ||
        raise(Common::CanNotFindEntity, :id => id)
    end

    def find_internal(id)
      id && store.find { |e| e.id == id.to_i }
    end

    def next_id
      @last_id += 1
    end

    attr_reader :store, :last_id
  end
end
