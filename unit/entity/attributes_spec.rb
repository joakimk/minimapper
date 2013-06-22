require 'minimapper/entity/core'
require 'minimapper/entity/attributes'

module Attribute
  class User
    include Minimapper::Entity::Core
    include Minimapper::Entity::Attributes
    attribute :id, Integer
    attribute  :name
  end

  class AgedUser < User
    attributes :age
  end

  class Project
    include Minimapper::Entity::Core
    include Minimapper::Entity::Attributes
    attributes :title
  end

  class Task
    include Minimapper::Entity::Core
    include Minimapper::Entity::Attributes

    attribute :due_at, DateTime
  end

  class OverridingUser
    include Minimapper::Entity::Core
    include Minimapper::Entity::Attributes
    attributes :name

    def name
      super.upcase
    end

    def name=(value)
      super(value.strip)
    end
  end
end

describe Minimapper::Entity::Attributes, "attributes without type" do
  let(:entity_class) do
    Class.new do
      include Minimapper::Entity::Core
      include Minimapper::Entity::Attributes
      attribute :name
    end
  end

  it "can be set and get with anything" do
    user = entity_class.new
    user.name = "Hello"
    user.name.should == "Hello"
    user.name = 5
    user.name.should == 5
  end
end

describe Minimapper::Entity::Attributes do
  it "can access attributes set at construction time" do
    entity = Attribute::User.new(:id => 5)
    entity.id.should == 5
    entity.attributes[:id].should == 5
  end

  it "can access attributes set through a hash" do
    entity = Attribute::User.new
    entity.attributes = { :id => 5 }
    entity.id.should == 5
    entity.attributes = { "id" => 8 }
    entity.id.should == 8
  end

  it "converts typed attributes" do
    entity = Attribute::User.new
    entity.id = "10"
    entity.id.should == 10
    entity.attributes = { :id => "15" }
    entity.id.should == 15
  end

  it "can use single line type declarations" do
    task = Attribute::Task.new(:due_at => "2012-01-01 15:00")
    task.due_at.should == DateTime.parse("2012-01-01 15:00")
  end

  it "sets blank values to nil" do
    user = Attribute::User.new
    user.name = "  "
    user.name.should be_nil
  end

  it "symbolizes keys" do
    entity = Attribute::User.new
    entity.attributes = { "id" => "15" }
    entity.attributes[:id].should == 15
  end

  it "inherits attributes" do
    user = Attribute::AgedUser.new
    user.name = "Name"
    user.age = 123
    user.name.should == "Name"
    user.age.should == 123
  end

  it "is possible to override attribute readers with inheritance" do
    user = Attribute::OverridingUser.new
    user.name = "pelle"
    user.name.should == "PELLE"
  end

  it "is possible to override attribute writers with inheritance" do
    user = Attribute::OverridingUser.new
    user.name = " 123 "
    user.name.should == "123"
  end
end

describe Minimapper::Entity::Attributes, "attributes" do
  it "returns the attributes" do
    entity = Attribute::User.new(:id => 5)
    time = Time.now
    entity.attributes.should == { :id => 5 }
  end
end

describe Minimapper::Entity::Attributes, "self.column_names" do
  it "returns all attributes as strings" do
    # used by some rails plugins
    Attribute::User.column_names.should == [ "id", "name" ]
  end

  it "does not leak between different models" do
    Attribute::Project.column_names.should == [ "title" ]
  end
end
