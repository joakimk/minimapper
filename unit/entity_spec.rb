require 'minimapper/entity'

class TestEntity
  include Minimapper::Entity
end

class TestUser
  include Minimapper::Entity
  attributes :name
end

class TestProject
  include Minimapper::Entity
  attributes :title
end

class TestTask
  include Minimapper::Entity

  attribute :due_at, :date_time
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

  it "can access attributes set through a hash" do
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

  it "can use single line type declarations" do
    task = TestTask.new(:due_at => "2012-01-01 15:00")
    task.due_at.should == DateTime.parse("2012-01-01 15:00")
  end

  it "sets blank values to nil" do
    user = TestUser.new
    user.name = "  "
    user.name.should be_nil
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

describe Minimapper::Entity, "self.column_names" do
  it "returns all attributes as strings" do
    # used by some rails plugins
    TestUser.column_names.should == [ "id", "created_at", "updated_at", "name" ]
  end

  it "does not leak between different models" do
    TestProject.column_names.should == [ "id", "created_at", "updated_at", "title" ]
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
