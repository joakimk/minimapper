require 'minimapper/entity/core'
require 'minimapper/entity/validation'

class ValidatableEntity
  include Minimapper::Entity::Core
  include Minimapper::Entity::Validation

  attr_accessor :name
  validates :name, :presence => true
end

describe Minimapper::Entity::Validation do
  it "includes active model validations" do
    entity = ValidatableEntity.new
    entity.should_not be_valid
    entity.name = "Joe"
    entity.should be_valid
  end

  describe "#mapper_errors=" do
    it "adds an error to the errors collection" do
      entity = ValidatableEntity.new
      entity.name = "Joe"
      entity.should be_valid
      entity.mapper_errors = [ [:name, "must be unique"] ]
      entity.should_not be_valid
      entity.errors[:name].should == ["must be unique"]
    end
  end
end
