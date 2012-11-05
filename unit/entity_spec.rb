require 'minimapper/entity'

class TestEntity
  include Minimapper::Entity
end

class TestUser
  include Minimapper::Entity
  attributes :name
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
    entity = TestUser.new(:id => 5)
    entity.id.should == 5
    entity.attributes[:id].should == 5
  end

  it "can access attributes set though a hash" do
    entity = TestUser.new
    entity.attributes = { :id => 5 }
    entity.id.should == 5
    entity.attributes = { "id" => 8 }
    entity.id.should == 8
  end

  it "converts typed attributes" do
    entity = TestEntity.new
    entity.id = "10"
    entity.id.should == 10
    entity.attributes = { :id => "15" }
    entity.id.should == 15
  end

  it "symbolizes keys" do
    entity = TestEntity.new
    entity.attributes = { "id" => "15" }
    entity.attributes[:id].should == 15
  end
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
