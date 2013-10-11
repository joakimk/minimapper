require "spec_helper"
require "minimapper/entity/core"
require "minimapper/mapper"

class Project
  include Minimapper::Entity::Core
end

class ProjectMapper < Minimapper::Mapper
  private

  class Record < ActiveRecord::Base
    attr_protected :visible

    validates :email,
      :uniqueness => true,
      :allow_nil => true

    self.table_name = :projects
    self.mass_assignment_sanitizer = :strict
  end
end

describe Minimapper::Mapper do
  let(:mapper) { ProjectMapper.new }
  let(:entity_class) { Project }

  it "can set and get repository" do
    mapper.repository = :repository_instance
    mapper.repository.should == :repository_instance
  end

  describe "#create" do
    it "sets an id on the entity" do
      entity1 = build_valid_entity
      entity1.id.should be_nil
      mapper.create(entity1)
      entity1.id.should > 0

      entity2 = build_valid_entity
      mapper.create(entity2)
      entity2.id.should == entity1.id + 1
    end

    it "marks the entity as persisted" do
      entity1 = build_valid_entity
      entity1.should_not be_persisted
      mapper.create(entity1)
      entity1.should be_persisted
    end

    it "returns the id" do
      id = mapper.create(build_valid_entity)
      id.should be_kind_of(Fixnum)
      id.should > 0
    end

    it "does not store by reference" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.last.object_id.should_not == entity.object_id
      mapper.last.attributes[:name].should == "test"
    end

    it "validates the record before saving" do
      entity = entity_class.new
      def entity.valid?
        false
      end
      mapper.create(entity).should be_false
    end

    it "calls before_save and after_save on the mapper" do
      entity = build_valid_entity
      record = ProjectMapper::Record.new
      ProjectMapper::Record.stub(:new => record)
      mapper.should_receive(:before_save).with(entity, record)
      mapper.should_receive(:after_save).with(entity, record)
      mapper.create(entity)
    end

    it "calls after_create on the mapper" do
      entity = build_valid_entity
      record = ProjectMapper::Record.new
      ProjectMapper::Record.stub(:new => record)
      mapper.should_receive(:after_create).with(entity, record)
      mapper.create(entity)
    end

    it "does not call after_save or after_create if the save fails" do
      entity = entity_class.new
      def entity.valid?
        false
      end
      mapper.should_receive(:before_save)
      mapper.should_not_receive(:after_save)
      mapper.should_not_receive(:after_create)
      mapper.create(entity)
    end

    it "does not include protected attributes" do
      # because it leads to exceptions when mass_assignment_sanitizer is set to strict
      entity = build_entity(:visible => true, :name => "Joe")
      mapper.create(entity)

      stored_entity = mapper.find(entity.id)
      stored_entity.attributes[:visible].should be_nil
      stored_entity.attributes[:name].should == "Joe"

      entity = Project.new
      entity.attributes = { :visible => true, :name => "Joe" }
      ProjectMapper::Record.stub(:protected_attributes => [])
      lambda { mapper.create(entity) }.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end

    it "copies record validation errors to entity" do
      old_entity = build_entity(:email => "joe@example.com")
      mapper.create(old_entity)
      old_entity.mapper_errors.should == []

      new_entity = build_entity(:email => "joe@example.com")
      mapper.create(new_entity)
      new_entity.mapper_errors.should == [ [:email, "has already been taken"] ]
    end

    it "can revalidate on record validation errors" do
      old_entity = build_entity(:email => "joe@example.com")
      mapper.create(old_entity)

      new_entity = build_entity(:email => "joe@example.com")
      mapper.create(new_entity)
      new_entity.mapper_errors.should == [ [:email, "has already been taken"] ]

      new_entity.attributes = { :email => "something.else@example.com" }
      mapper.create(new_entity)
      new_entity.should be_valid
    end
  end

  describe "#create!" do
    it "can create records" do
      entity = build_valid_entity
      mapper.create!(entity)
      entity.should be_persisted
    end

    it "raises Minimapper::EntityInvalid when the entity is invalid" do
      entity = entity_class.new
      def entity.valid?
        false
      end
      -> { mapper.create!(entity) }.should raise_error(Minimapper::EntityInvalid)
    end
  end

  describe "#find" do
    it "returns an entity matching the id" do
      entity = build_valid_entity
      mapper.create(entity)
      found_entity = mapper.find(entity.id)
      found_entity.attributes[:name].should == "test"
      found_entity.id.should == entity.id
      found_entity.should be_kind_of(Minimapper::Entity::Core)
    end

    it "supports string ids" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.find(entity.id.to_s)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.find(entity.id).object_id.should_not == entity.object_id
      mapper.find(entity.id).object_id.should_not == mapper.find(entity.id).object_id
    end

    it "calls after_find on the mapper" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.should_receive(:after_find)
      found_entity = mapper.find(entity.id)
    end

    it "returns an entity marked as persisted" do
      entity = build_valid_entity
      mapper.create(entity)
      found_entity = mapper.find(entity.id)
      found_entity.should be_persisted
    end

    it "fails when an entity can not be found" do
      lambda { mapper.find(-1) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#find_by_id" do
    it "returns an entity matching the id" do
      entity = build_valid_entity
      mapper.create(entity)
      found_entity = mapper.find_by_id(entity.id)
      found_entity.attributes[:name].should == "test"
      found_entity.id.should == entity.id
      found_entity.should be_kind_of(Minimapper::Entity::Core)
    end

    it "supports string ids" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.find_by_id(entity.id.to_s)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.find_by_id(entity.id).object_id.should_not == entity.object_id
      mapper.find_by_id(entity.id).object_id.should_not == mapper.find_by_id(entity.id).object_id
    end

    it "returns nil when an entity can not be found" do
      mapper.find_by_id(-1).should be_nil
    end
  end

  describe "#all" do
    it "returns all entities in undefined order" do
      first_created_entity = build_valid_entity
      second_created_entity = build_valid_entity
      mapper.create(first_created_entity)
      mapper.create(second_created_entity)
      all_entities = mapper.all
      all_entities.map(&:id).should include(first_created_entity.id)
      all_entities.map(&:id).should include(second_created_entity.id)
      all_entities.first.should be_kind_of(Minimapper::Entity::Core)
    end

    it "does not return the same instances" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.all.first.object_id.should_not == entity.object_id
      mapper.all.first.object_id.should_not == mapper.all.first.object_id
    end
  end

  describe "#first" do
    it "returns the first entity" do
      first_created_entity = build_valid_entity
      mapper.create(first_created_entity)
      mapper.create(build_valid_entity)
      mapper.first.id.should == first_created_entity.id
      mapper.first.should be_kind_of(entity_class)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.first.object_id.should_not == entity.object_id
      mapper.first.object_id.should_not == mapper.first.object_id
    end

    it "returns nil when there is no entity" do
      mapper.first.should be_nil
    end
  end

  describe "#last" do
    it "returns the last entity" do
      last_created_entity = build_valid_entity
      mapper.create(build_valid_entity)
      mapper.create(last_created_entity)
      mapper.last.id.should == last_created_entity.id
      mapper.last.should be_kind_of(entity_class)
    end

    it "does not return the same instance" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.last.object_id.should_not == entity.object_id
      mapper.last.object_id.should_not == mapper.last.object_id
    end

    it "returns nil when there is no entity" do
      mapper.last.should be_nil
    end
  end

  describe "#reload" do
    it "reloads the given record" do
      entity = build_entity(:email => "foo@example.com")
      mapper.create(entity)
      entity.attributes[:email] = "test@example.com"
      mapper.reload(entity)
      entity.attributes[:email] = "foo@example.com"
      mapper.reload(entity).object_id.should_not == entity.object_id
    end
  end

  describe "#count" do
    it "returns the number of entities" do
      mapper.create(build_valid_entity)
      mapper.create(build_valid_entity)
      mapper.count.should == 2
    end
  end

  describe "#update" do
    it "updates" do
      entity = build_valid_entity
      mapper.create(entity)

      entity.attributes = { :name => "Updated" }
      mapper.last.attributes[:name].should == "test"

      mapper.update(entity)
      mapper.last.id.should == entity.id
      mapper.last.attributes[:name].should == "Updated"
    end

    it "does not update and returns false when the entity isn't valid" do
      entity = build_valid_entity
      mapper.create(entity)

      def entity.valid?
        false
      end

      mapper.update(entity).should be_false
      mapper.last.attributes[:name].should == "test"
    end

    it "calls before_save and after_save on the mapper" do
      entity = build_valid_entity
      mapper.create(entity)

      record = ProjectMapper::Record.last
      ProjectMapper::Record.stub(:find_by_id => record)

      mapper.should_receive(:before_save).with(entity, record)
      mapper.should_receive(:after_save).with(entity, record)
      mapper.update(entity)
    end

    it "does not call after_create" do
      entity = build_valid_entity
      mapper.create(entity)

      record = ProjectMapper::Record.last
      ProjectMapper::Record.stub(:find_by_id => record)

      mapper.should_receive(:after_save)
      mapper.should_not_receive(:after_create)
      mapper.update(entity)
    end

    it "returns true" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.update(entity).should == true
    end

    it "fails when the entity does not have an id" do
      entity = build_valid_entity
      lambda { mapper.update(entity) }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "fails when the entity no longer exists" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.delete_all
      lambda { mapper.update(entity) }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not include protected attributes" do
      entity = Project.new
      mapper.create(entity)

      entity.attributes = { :visible => true, :name => "Joe" }
      mapper.update(entity)
      stored_entity = mapper.find(entity.id)
      stored_entity.attributes[:visible].should be_nil
      stored_entity.attributes[:name].should == "Joe"

      ProjectMapper::Record.stub(:protected_attributes => [])
      lambda { mapper.update(entity) }.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end

    it "copies record validation errors to entity" do
      old_entity = build_entity(:email => "joe@example.com")
      mapper.create(old_entity)

      new_entity = Project.new
      mapper.create(new_entity)
      new_entity.mapper_errors.should == []

      new_entity.attributes = { :email => "joe@example.com" }
      mapper.update(new_entity)
      new_entity.mapper_errors.should == [ [:email, "has already been taken"] ]
    end

    it "can revalidate on record validation errors" do
      old_entity = build_entity(:email => "joe@example.com")
      mapper.create(old_entity)

      new_entity = Project.new
      mapper.create(new_entity)
      new_entity.mapper_errors.should == []

      new_entity.attributes = { :email => "joe@example.com" }
      mapper.update(new_entity)
      new_entity.mapper_errors.should == [ [:email, "has already been taken"] ]

      new_entity.attributes = { :email => "something.else@example.com" }
      mapper.update(new_entity)
      new_entity.should be_valid
    end
  end

  describe "#update!" do
    it "can update records" do
      entity = build_valid_entity
      mapper.create(entity)
      entity.attributes[:email] = "updated@example.com"
      mapper.update!(entity)
      mapper.reload(entity).attributes[:email].should == "updated@example.com"
    end

    it "raises Minimapper::EntityInvalid when the entity is invalid" do
      entity = build_valid_entity
      mapper.create(entity)
      def entity.valid?
        false
      end
      -> { mapper.update!(entity) }.should raise_error(Minimapper::EntityInvalid)
    end
  end

  describe "#delete" do
    it "removes the entity" do
      entity = build_valid_entity
      removed_entity_id = entity.id
      mapper.create(entity)
      mapper.create(build_valid_entity)
      mapper.delete(entity)
      mapper.all.size.should == 1
      mapper.first.id.should_not == removed_entity_id
    end

    it "marks the entity as no longer persisted" do
      entity = build_valid_entity
      mapper.create(entity)
      entity.should be_persisted
      mapper.delete(entity)
      entity.should_not be_persisted
    end

    it "fails when the entity does not have an id" do
      entity = entity_class.new
      lambda { mapper.delete(entity) }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "fails when the entity can not be found" do
      entity = entity_class.new
      entity.id = -1
      lambda { mapper.delete(entity) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#delete_by_id" do
    it "removes the entity" do
      entity = build_valid_entity
      mapper.create(entity)
      mapper.create(build_valid_entity)
      mapper.delete_by_id(entity.id)
      mapper.all.size.should == 1
      mapper.first.id.should_not == entity.id
    end

    it "fails when an entity can not be found" do
      lambda { mapper.delete_by_id(-1) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#delete_all" do
    it "empties the mapper" do
      mapper.create(build_valid_entity)
      mapper.delete_all
      mapper.all.should == []
    end
  end

  private

  def build_valid_entity
    entity = entity_class.new
    entity.attributes = { :name => 'test' }
    entity
  end

  def build_entity(attributes)
    entity = Project.new
    entity.attributes = attributes
    entity
  end
end
