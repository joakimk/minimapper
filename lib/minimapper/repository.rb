module Minimapper
  class Repository
    def self.build(mappers)
      new(mappers)
    end

    def initialize(mappers)
      @mappers = mappers
      define_mapper_methods
    end

    def delete_all!
      mappers.each { |name, instance| instance.delete_all }
    end

    private

    def define_mapper_methods
      mappers.each do |name, instance|
        singleton = (class << self; self end)
        singleton.send(:define_method, name) do # def mapper_name
          instance                              #   instance
        end                                     # end
      end
    end

    attr_reader :mappers
  end
end
