module Minimapper
  module Entity
    class Convert
      class ToDateTime
        def convert(value)
          DateTime.parse(value) rescue nil
        end
      end
    end
  end
end
