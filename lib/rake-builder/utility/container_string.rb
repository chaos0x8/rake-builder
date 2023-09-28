require_relative 'container'

module RakeBuilder
  module Utility
    class ContainerString < Container
      private

      def append(val)
        super val.to_s
      end
    end
  end
end
