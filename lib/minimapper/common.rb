module Minimapper
  module Common
    CanNotFindEntity = Class.new(StandardError)

    attr_accessor :repository
  end
end
