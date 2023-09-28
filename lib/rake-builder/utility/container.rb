require_relative '../error/unsuported_type'

require 'pathname'

module RakeBuilder
  module Utility
    class Container
      include Enumerable

      def initialize
        @value = []
      end

      def <<(val)
        case val
        when ::Array
          val.each do |v|
            self << v
          end
        when ::String, ::Pathname, ::Symbol
          append val
        when Utility::Container
          val.each do |v|
            self << v
          end
        when Project::TrackedList
          append val.path
        else
          raise Error::UnsuportedType, val
        end

        self
      end

      def to_a
        @value
      end

      def each(&block)
        @value.each(&block)
      end

      def size
        @value.size
      end

      private

      def append(val)
        @value << val
      end
    end
  end
end
