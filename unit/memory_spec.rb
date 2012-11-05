require 'minimapper/memory'
require 'minimapper/entity/core'

class BasicEntity
  include Minimapper::Entity::Core
end

describe Minimapper::Memory do
  let(:repository) { described_class.new }
  let(:entity_class) { BasicEntity }

  include_examples :mapper
end
