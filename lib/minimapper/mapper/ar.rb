require "minimapper/mapper/common"

module Minimapper
  module Mapper
    class AR
      include Common

      # Create

      def create(entity)
        record = record_class.new
        validate_record_and_copy_errors_to_entity(record, entity)

        if entity.valid?
          record.save!
          entity.id = record.id
          entity.id
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
        entities_for record_class.all
      end

      def first
        entity_for(record_class.order("id ASC").first)
      end

      def last
        entity_for(record_class.order("id ASC").last)
      end

      def count
        record_class.count
      end

      # Update

      def update(entity)
        record = record_for(entity)
        validate_record_and_copy_errors_to_entity(record, entity)

        if entity.valid?
          record.save!
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
        record_class.delete_all
      end

      private

      # NOTE: Don't memoize the classes or code reloading will break in rails apps.

      # Will attempt to use AR:Project as the record class
      # when the mapper class name is AR::ProjectMapper
      def record_class
        self.class.name.sub(/Mapper$/, '').constantize
      end

      # Will attempt to use Project as the enity class when
      # the mapper class name is AR::ProjectMapper
      def entity_class
        ("::" + self.class.name.split('::').last.sub(/Mapper$/, '')).constantize
      end

      def accessible_attributes(entity)
        entity.attributes.reject { |k, v| protected_attributes.include?(k.to_s) }
      end

      def protected_attributes
        record_class.protected_attributes
      end

      def validate_record_and_copy_errors_to_entity(record, entity)
        record.attributes = accessible_attributes(entity)
        record.valid?
        entity.mapper_errors = record.errors.map { |k, v| [k, v] }
      end

      def find_record_safely(id)
        find_record(id) ||
          raise(CanNotFindEntity, :id => id)
      end

      def find_record(id)
        id && record_class.find_by_id(id)
      end

      def record_for(entity)
        (entity.id && record_class.find_by_id(entity.id)) ||
          raise(CanNotFindEntity, entity.inspect)
      end

      def entities_for(records)
        records.map { |record| entity_for(record) }
      end

      def entity_for(record, klass = entity_class)
        if record
          entity = klass.new
          entity.id = record.id
          entity.attributes = record.attributes.symbolize_keys
          entity
        else
          nil
        end
      end
    end
  end
end
