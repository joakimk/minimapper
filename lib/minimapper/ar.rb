require "minimapper/common"

module Minimapper
  class AR
    # Create
    def create(entity)
      if entity.valid?
        entity.id = record_klass.create!(entity.attributes).id
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
      record_klass.all.map { |record| entity_klass.new(record.attributes) }
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
        record_for(entity).update_attributes!(entity.attributes)
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
    def entity_klass
      @entity_klass ||= ("::" + self.class.name.split('::').last.gsub(/Mapper/, '')).constantize
      @entity_klass
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

    def entity_for(record)
      if record
        entity_klass.new(record.attributes)
      else
        nil
      end
    end
  end
end
