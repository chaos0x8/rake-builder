require_relative '../utility/to_pathname'

module RakeBuilder
  module Attr
    class Path
      def initialize
        @value = Utility.to_pathname('')
      end

      attr_reader :value

      def value?
        @value && !@value.to_s.empty?
      end

      def <<(val)
        @value = Utility.to_pathname(val)
      end
    end
  end
end
