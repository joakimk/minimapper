require 'minimapper/entity/core'
require 'minimapper/entity/rails'

class RailsEntity
  include Minimapper::Entity::Core
  include Minimapper::Entity::Rails
end

describe Minimapper::Entity::Rails do
  it "responds to new_record?" do
    entity = RailsEntity.new
    entity.should be_new_record
    entity.id = 5
    entity.should_not be_new_record
  end

  it "responds to to_model" do
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
end
