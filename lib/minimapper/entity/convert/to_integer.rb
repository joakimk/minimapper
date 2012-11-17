module Minimapper
  module Entity
    class Convert
      class ToInteger
        def convert(value)
          if value =~ /[0-9]/
            value.to_i
          else
            nil
          end
        end
      end
    end
  end
end
