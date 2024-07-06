module RakeBuilder
  module Attr
    class String
      def initialize
        @value = ''
      end

      attr_reader :value

      def value?
        @value && !@value.empty?
      end

      def <<(val)
        @value = val
      end
    end
  end
end
