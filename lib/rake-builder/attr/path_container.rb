require_relative '../utility/to_pathname'

module RakeBuilder
  module Attr
    class PathContainer < Container
      private

      def __append__(val)
        @value << Utility.to_pathname(val)
      end
    end
  end
end
