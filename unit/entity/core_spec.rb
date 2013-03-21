require 'minimapper/entity/core'

class BasicEntity
  include Minimapper::Entity::Core
  attr_accessor :one, :two
end

class OtherEntity
  include Minimapper::Entity::Core
end

describe Minimapper::Entity::Core do
  it "can get and set an attributes hash" do
    entity = BasicEntity.new
    entity.attributes.should == {}
    entity.attributes = { :one => 1 }
    entity.attributes.should == { :one => 1 }
  end

  it "does not replace the existing hash" do
    entity = BasicEntity.new
    entity.attributes = { :one => 1 }
    entity.attributes = { :two => 2 }
    entity.attributes.should == { :one => 1, :two => 2 }
  end

  it "converts all keys to symbols" do
    entity = BasicEntity.new
    entity.attributes = { :one => 1 }
    entity.attributes = { "one" => 11 }
    entity.attributes.should == { :one => 11 }
  end

  it "responds to id" do
    entity = BasicEntity.new
    entity.id = 10
    entity.id.should == 10
  end

  describe "#mapper_errors" do
    it "defaults to an empty array" do
      entity = BasicEntity.new
      entity.mapper_errors.should == []
    end

    it "can be changed" do
      entity = BasicEntity.new
      entity.mapper_errors = [ [:one, "bad"] ]
      entity.mapper_errors.should == [ [:one, "bad"] ]
    end
  end

  describe "#mapper_errors=" do
    it "makes the mapper invalid if present" do
      entity = BasicEntity.new
      entity.mapper_errors = [ [:one, "bad"] ]
      entity.valid?.should be_false
    end
  end

  describe "#valid?" do
    it "is true without errors" do
      entity = BasicEntity.new
      entity.valid?.should be_true
    end

    it "is false with errors" do
      entity = BasicEntity.new
      entity.mapper_errors = [ [:one, "bad"] ]
      entity.valid?.should be_false
    end
  end

  describe "#==" do
    it "is equal to the exact same instance" do
      entity = build_entity(BasicEntity, nil)
      entity.should == entity
    end

    it "is equal to another instance if class and id matches" do
      entity = build_entity(BasicEntity,  123)
      other_entity = build_entity(BasicEntity,  123)
      entity.should == other_entity
    end

    it "is not equal to another instance if there is no id" do
      entity = build_entity(BasicEntity, nil)
      other_entity = build_entity(BasicEntity, nil)
      entity.should_not == other_entity
    end

    it "is not equal to another instance if ids do not match" do
      entity = build_entity(BasicEntity,  123)
      other_entity = build_entity(BasicEntity,  456)
      entity.should_not == other_entity
    end

    it "is not equal to another instance if classes do not match" do
      entity = build_entity(BasicEntity, 123)
      other_entity = build_entity(OtherEntity, 123)
      entity.should_not == other_entity
    end

    def build_entity(klass, id)
      entity = klass.new
      entity.id = id
      entity
    end
  end
end
