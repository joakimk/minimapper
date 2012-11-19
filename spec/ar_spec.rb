require "spec_helper"
require "minimapper/entity/core"
require "minimapper/ar"

class TestEntity
  include Minimapper::Entity::Core
end

class TestMapper < Minimapper::AR
  private

  def entity_class
    TestEntity
  end

  def record_klass
    Record
  end

  class Record < ActiveRecord::Base
    attr_accessible :name
    self.table_name = :projects
  end
end

describe Minimapper::AR do
  let(:mapper) { TestMapper.new }
  let(:entity_class) { TestEntity }

  include_examples :mapper
end
