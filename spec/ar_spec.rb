require "spec_helper"
require "minimapper/entity"
require "minimapper/ar"

class TestEntity
  include Minimapper::Entity
  attributes :name, :github_url
  validates :name, :presence => true
end

class TestMapper < Minimapper::AR
  private

  def entity_klass
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
  let(:repository) { TestMapper.new }
  let(:entity_klass) { TestEntity }

  include_examples :mapper
end
