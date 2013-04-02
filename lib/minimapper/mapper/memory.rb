require 'minimapper/mapper/common'

module Minimapper
  module Mapper
    class Memory
      include Common

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

      def find_by_id(id)
        entity = find_internal(id)
        entity && entity.dup
      end

      def all
        store.map { |entity| entity.dup }
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
          raise(EntityNotFound, :id => id)
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
end
