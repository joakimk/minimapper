require 'minimapper/entity'

class TestEntity
  include Minimapper::Entity
end

describe Minimapper::Entity do
  it "handles base attributes" do
    entity = TestEntity.new
    entity.id = 5
    entity.id.should == 5

    time = Time.now
    entity.created_at = time
    entity.created_at.should == time

    entity.updated_at = time
    entity.updated_at.should == time
  end

  it "can access attributes set at construction time" do
    entity = TestEntity.new(:id => 5)
    entity.id.should == 5
  end

  it "converts typed attributes" do
    entity = TestEntity.new
    entity.id = "10"
    entity.id.should == 10
  end
end

class TestUser
  include Minimapper::Entity
  attributes :name
end

describe Minimapper::Entity, "attributes without type" do
  it "can be set and get with anything" do
    user = TestUser.new
    user.name = "Hello"
    user.name.should == "Hello"
    user.name = 5
    user.name.should == 5
  end
end

describe Minimapper::Entity, "attributes" do
  it "returns the attributes" do
    entity = TestEntity.new(:id => 5)
    time = Time.now
    entity.created_at = time
    entity.attributes.should == { :id => 5, :created_at => time }
  end
end

describe Minimapper::Entity, "to_param" do
  it "responds with the id to be compatible with rails link helpers" do
    entity = TestEntity.new(:id => 5)
    entity.to_param.should == 5
  end
end

describe Minimapper::Entity, "persisted?" do
  it "responds true when there is an id (to be compatible with rails form helpers)" do
    entity = TestEntity.new
    entity.should_not be_persisted
    entity.id = 5
    entity.should be_persisted
  end
end
