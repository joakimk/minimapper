module Minimapper
  class Memory
    def initialize
      @store = []
      @last_id = 0
    end

    def add(entity)
      if entity.valid?
        entity.id = next_id
        store.push(entity.dup)
        last_id
      else
        false
      end
    end

    def find(id)
      find_internal(id).dup
    end

    def update(entity)
      if entity.valid?
        known_entity = find_internal(entity.id)
        known_entity.attributes = entity.attributes
        true
      else
        false
      end
    end

    def delete(entity)
      delete_by_id(entity.id)
    end

    def delete_by_id(id)
      entity = find_internal(id)
      store.delete(entity)
    end

    def delete_all
      store.clear
    end

    def first
      store.first && store.first.dup
    end

    def last
      store.last && store.last.dup
    end

    def count
      all.size
    end

    def all
      store.dup
    end

    private

    def find_internal(id)
      (id && store.find { |e| e.id == id.to_i }) ||
        raise(Common::CanNotFindEntity, id: id)
    end

    def next_id
      @last_id += 1
    end

    attr_reader :store, :last_id
  end
end
