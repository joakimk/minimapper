require 'minimapper/entity/core'

class BasicEntity
  include Minimapper::Entity::Core
  attr_accessor :one, :two
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

  it "returns true for valid?" do
    entity = BasicEntity.new
    entity.should be_valid
  end

  it "responds to id" do
    entity = BasicEntity.new
    entity.id = 10
    entity.id.should == 10
  end
end
