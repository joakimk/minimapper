require 'minimapper/mapper/memory'
require 'minimapper/entity/core'

class BasicEntity
  include Minimapper::Entity::Core
end

describe Minimapper::Mapper::Memory do
  let(:mapper) { described_class.new }
  let(:entity_class) { BasicEntity }

  include_examples :mapper
end
