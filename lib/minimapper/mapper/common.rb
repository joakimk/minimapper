module Minimapper
  EntityNotFound = Class.new(StandardError)

  module Mapper
    module Common
      attr_accessor :repository
    end
  end
end
