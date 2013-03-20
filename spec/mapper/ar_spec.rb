require "spec_helper"
require "minimapper/entity/core"
require "minimapper/mapper/ar"

class TestEntity
  include Minimapper::Entity::Core
end

class TestMapper < Minimapper::Mapper::AR
  private

  def entity_class
    TestEntity
  end

  def record_class
    Record
  end

  class Record < ActiveRecord::Base
    attr_protected :visible

    validates :email,
      :uniqueness => true,
      :allow_nil => true

    self.table_name = :projects
    self.mass_assignment_sanitizer = :strict
  end
end

describe Minimapper::Mapper::AR do
  let(:mapper) { TestMapper.new }
  let(:entity_class) { TestEntity }

  include_examples :mapper

  describe "#create" do
    it "does not include protected attributes" do
      # because it leads to exceptions when mass_assignment_sanitizer is set to strict
      entity = build_entity(:visible => true, :name => "Joe")
      mapper.create(entity)

      stored_entity = mapper.find(entity.id)
      stored_entity.attributes[:visible].should be_nil
      stored_entity.attributes[:name].should == "Joe"

      entity = TestEntity.new
      entity.attributes = { :visible => true, :name => "Joe" }
      TestMapper::Record.stub(:protected_attributes => [])
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

    def build_entity(attributes)
      entity = TestEntity.new
      entity.attributes = attributes
      entity
    end
  end

  describe "#update" do
    it "does not include protected attributes" do
      entity = TestEntity.new
      mapper.create(entity)

      entity.attributes = { :visible => true, :name => "Joe" }
      mapper.update(entity)
      stored_entity = mapper.find(entity.id)
      stored_entity.attributes[:visible].should be_nil
      stored_entity.attributes[:name].should == "Joe"

      TestMapper::Record.stub(:protected_attributes => [])
      lambda { mapper.update(entity) }.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end

    it "copies record validation errors to entity" do
      old_entity = build_entity(:email => "joe@example.com")
      mapper.create(old_entity)

      new_entity = TestEntity.new
      mapper.create(new_entity)
      new_entity.mapper_errors.should == []

      new_entity.attributes = { :email => "joe@example.com" }
      mapper.update(new_entity)
      new_entity.mapper_errors.should == [ [:email, "has already been taken"] ]
    end

    it "can revalidate on record validation errors" do
      old_entity = build_entity(:email => "joe@example.com")
      mapper.create(old_entity)

      new_entity = TestEntity.new
      mapper.create(new_entity)
      new_entity.mapper_errors.should == []

      new_entity.attributes = { :email => "joe@example.com" }
      mapper.update(new_entity)
      new_entity.mapper_errors.should == [ [:email, "has already been taken"] ]

      new_entity.attributes = { :email => "something.else@example.com" }
      mapper.update(new_entity)
      new_entity.should be_valid
    end

    def build_entity(attributes)
      entity = TestEntity.new
      entity.attributes = attributes
      entity
    end
  end
end
