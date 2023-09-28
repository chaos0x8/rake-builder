require_relative 'container_string'

module RakeBuilder
  module Utility
    class ContainerFlag < ContainerString
      def initialize(parent_flags_ = nil)
        super()
        @parent_flags = parent_flags_
      end

      def each(&block)
        to_a.each(&block)
      end

      def size
        to_a.size
      end
    end
  end
end
