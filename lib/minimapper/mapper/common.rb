module Minimapper
  module Mapper
    CanNotFindEntity = Class.new(StandardError)

    module Common
      attr_accessor :repository
    end
  end
end
