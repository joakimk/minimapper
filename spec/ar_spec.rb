require "spec_helper"
require "minimapper/entity/core"
require "minimapper/ar"

class TestEntity
  include Minimapper::Entity::Core
end

class TestMapper < Minimapper::AR
  private

  def entity_class
    TestEntity
  end

  def record_klass
    Record
  end

  class Record < ActiveRecord::Base
    attr_protected :visible

    self.table_name = :projects
    self.mass_assignment_sanitizer = :strict
  end
end

describe Minimapper::AR do
  let(:mapper) { TestMapper.new }
  let(:entity_class) { TestEntity }

  include_examples :mapper

  describe "#create" do
    it "does not include protected attributes" do
      # because it leads to exceptions when mass_assignment_sanitizer is set to strict
      entity = TestEntity.new
      entity.attributes = { :visible => true, :name => "Joe" }
      mapper.create(entity)

      stored_entity = mapper.find(entity.id)
      stored_entity.attributes[:visible].should be_nil
      stored_entity.attributes[:name].should == "Joe"

      entity = TestEntity.new
      entity.attributes = { :visible => true, :name => "Joe" }
      TestMapper::Record.stub(protected_attributes: [])
      -> { mapper.create(entity) }.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
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

      TestMapper::Record.stub(protected_attributes: [])
      -> { mapper.update(entity) }.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
end
