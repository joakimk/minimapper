require 'minimapper/entity/rails'
require 'minimapper/entity/core'

class RailsEntity
  include Minimapper::Entity::Core
  include Minimapper::Entity::Rails

  attr_accessor :name
  validates :name, :presence => true
end

describe Minimapper::Entity::Rails do
  it "responds to new_record?" do
    entity = RailsEntity.new
    entity.should be_new_record
    entity.id = 5
    entity.should_not be_new_record
  end

  it "resonds to to_model" do
    entity = RailsEntity.new
    entity.to_model.should == entity
  end

  it "responds to to_key" do
    entity = RailsEntity.new
    entity.to_key.should be_nil
    entity.id = 5
    entity.to_key.should == [ 5 ]
  end

  # for rails link helpers
  it "responds to to_param" do
    entity = RailsEntity.new
    entity.id = 5
    entity.to_param.should == 5
  end

  # for rails form helpers
  it "responds to persisted?" do
    entity = RailsEntity.new
    entity.should_not be_persisted
    entity.id = 5
    entity.should be_persisted
  end

  it "includes active model validations" do
    entity = RailsEntity.new
    entity.should_not be_valid
    entity.name = "Joe"
    entity.should be_valid
  end

  describe "#mapper_errors=" do
    it "adds an error to the errors collection" do
      entity = RailsEntity.new
      entity.name = "Joe"
      entity.should be_valid
      entity.mapper_errors = [ [:name, "must be unique"] ]
      entity.should_not be_valid
      entity.errors[:name].should == ["must be unique"]
    end
  end
end
