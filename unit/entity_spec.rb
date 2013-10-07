require 'minimapper/entity'

class TestUser
  include Minimapper::Entity
  attributes :name
end

class TestProject
  include Minimapper::Entity
  attributes :title
end

describe Minimapper::Entity do
  let(:entity_class) do
    Class.new do
      include Minimapper::Entity
    end
  end

  it "handles base attributes" do
    entity = entity_class.new

    entity.id = 5
    entity.id.should == 5

    time = DateTime.now
    entity.created_at = time
    entity.created_at.should == time

    entity.updated_at = time
    entity.updated_at.should == time
  end
end

describe Minimapper::Entity, "#==" do
  it "is equal to the exact same instance" do
    entity = build_entity(TestUser, nil)
    entity.should == entity
  end

  it "is equal to another instance if class and id matches" do
    entity = build_entity(TestUser,  123)
    other_entity = build_entity(TestUser,  123)
    entity.should == other_entity
  end

  it "is not equal to another instance if there is no id" do
    entity = build_entity(TestUser, nil)
    other_entity = build_entity(TestUser, nil)
    entity.should_not == other_entity
  end

  it "is not equal to another instance if ids do not match" do
    entity = build_entity(TestUser,  123)
    other_entity = build_entity(TestUser,  456)
    entity.should_not == other_entity
  end

  it "is not equal to another instance if classes do not match" do
    entity = build_entity(TestUser, 123)
    other_entity = build_entity(TestProject, 123)
    entity.should_not == other_entity
  end

  def build_entity(klass, id)
    entity = klass.new
    entity.id = id
    entity
  end
end
