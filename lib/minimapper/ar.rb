require "minimapper/common"

module Minimapper
  class AR
    include Common

    # Create
    def create(entity)
      if entity.valid?
        entity.id = record_klass.create!(accessible_attributes(entity)).id
      else
        false
      end
    end

    # Read
    def find(id)
      entity_for(find_record_safely(id))
    end

    def find_by_id(id)
      entity_for(find_record(id))
    end

    def all
      entities_for record_klass.all
    end

    def first
      entity_for(record_klass.order("id ASC").first)
    end

    def last
      entity_for(record_klass.order("id ASC").last)
    end

    def count
      record_klass.count
    end

    # Update
    def update(entity)
      if entity.valid?
        record_for(entity).update_attributes!(accessible_attributes(entity))
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
      find_record_safely(id).delete
    end

    def delete_all
      record_klass.delete_all
    end

    private

    # TODO: write tests for these, they are indirectly tested by the fact
    # that the test suite runs, but there could be bugs and I'll extract minimapper soon.

    # Will attempt to use AR:Project as the record class
    # when the mapper class name is AR::ProjectMapper
    def record_klass
      @record_klass ||= self.class.name.gsub(/Mapper/, '').constantize
      @record_klass
    end

    # Will attempt to use Project as the enity class when
    # the mapper class name is AR::ProjectMapper
    def entity_class
      @entity_class ||= ("::" + self.class.name.split('::').last.gsub(/Mapper/, '')).constantize
      @entity_class
    end

    def accessible_attributes(entity)
      entity.attributes.reject { |k, v| protected_attributes.include?(k.to_s) }
    end

    def protected_attributes
      record_klass.protected_attributes
    end

    def find_record_safely(id)
      find_record(id) ||
        raise(Common::CanNotFindEntity, :id => id)
    end

    def find_record(id)
      id && record_klass.find_by_id(id)
    end

    def record_for(entity)
      (entity.id && record_klass.find_by_id(entity.id)) ||
        raise(Common::CanNotFindEntity, entity.inspect)
    end

    def entities_for(records)
      records.map { |record| entity_for(record) }
    end

    def entity_for(record)
      if record
        entity = entity_class.new
        entity.id = record.id
        entity.attributes = record.attributes.symbolize_keys
        entity
      else
        nil
      end
    end
  end
end
