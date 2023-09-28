require_relative 'container'
require_relative 'to_pathname'

module RakeBuilder
  module Utility
    class ContainerPath < Container
      private

      def append(val)
        super Utility.to_pathname(val)
      end
    end
  end
end
