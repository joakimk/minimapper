require "minimapper/entity_invalid"

module Minimapper
  class Mapper
    attr_accessor :repository

    # Create

    def create(entity)
      record = record_class.new

      with_save_hooks(entity, record) do
        copy_attributes_to_record(record, entity)
        validate_record_and_copy_errors_to_entity(record, entity)

        if entity.valid?
          record.save!
          entity.mark_as_persisted
          entity.id = record.id
          entity.id
        else
          false
        end
      end
    end

    def create!(entity)
      create(entity) || raise(Minimapper::EntityInvalid.new(entity))
    end

    # Read

    def find(id)
      entity_for(find_record_safely(id))
    end

    def find_by_id(id)
      entity_for(find_record(id))
    end

    def all
      entities_for query_scope.all
    end

    def first
      entity_for(query_scope.order("id ASC").first)
    end

    def last
      entity_for(query_scope.order("id ASC").last)
    end

    def reload(entity)
      find(entity.id)
    end

    def count
      query_scope.count
    end

    # Update

    def update(entity)
      record = record_for(entity)

      with_save_hooks(entity, record) do
        copy_attributes_to_record(record, entity)
        validate_record_and_copy_errors_to_entity(record, entity)

        if entity.valid?
          record.save!
          true
        else
          false
        end
      end
    end

    def update!(entity)
      update(entity) || raise(Minimapper::EntityInvalid.new(entity))
    end

    # Delete

    def delete(entity)
      delete_by_id(entity.id)
      entity.mark_as_not_persisted
    end

    def delete_by_id(id)
      find_record_safely(id).delete
    end

    def delete_all
      query_scope.delete_all
    end

    private

    def accessible_attributes(entity)
      entity.attributes.reject { |k, v| protected_attributes.include?(k.to_s) }
    end

    def protected_attributes
      record_class.protected_attributes
    end

    def copy_attributes_to_record(record, entity)
      record.attributes = accessible_attributes(entity)
    end

    def validate_record_and_copy_errors_to_entity(record, entity)
      record.valid?
      entity.mapper_errors = record.errors.map { |k, v| [k, v] }
    end

    def find_record_safely(id)
      query_scope.find(id)
    end

    def find_record(id)
      id && query_scope.find_by_id(id)
    end

    def record_for(entity)
      query_scope.find(entity.id)
    end

    def entities_for(records, klass = entity_class)
      records.map { |record| entity_for(record, klass) }
    end

    def entity_for(record, klass = entity_class)
      if record
        entity = klass.new
        entity.id = record.id
        entity.mark_as_persisted
        entity.attributes = record.attributes.symbolize_keys

        if klass == entity_class
          after_find(entity, record)
        end

        entity
      else
        nil
      end
    end

    def with_save_hooks(entity, record)
      creating = record.new_record?
      before_save(entity, record)
      result = yield

      if result
        after_save(entity, record)

        if creating
          after_create(entity, record)
        end
      end

      result
    end

    # Override to customize default includes etc that apply to all queries
    def query_scope
      record_class
    end

    # NOTE: Don't memoize the record_class or code reloading will break in rails apps.
    def record_class
      "#{self.class.name}::Record".constantize
    end

    # Will attempt to use Project as the entity class when
    # the mapper class name is ProjectMapper.
    def entity_class
      self.class.name.sub(/Mapper$/, '').constantize
    end

    # Hooks

    def after_find(entity, record)
    end

    def before_save(entity, record)
    end

    def after_save(entity, record)
    end

    def after_create(entity, record)
    end
  end
end
