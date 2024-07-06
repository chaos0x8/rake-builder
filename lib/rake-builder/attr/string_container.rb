require_relative 'container'

module RakeBuilder
  module Attr
    class StringContainer < Container
      def self.def_hierarhy_get(attribute)
        define_method attribute do
          if parent = instance_variable_get(:@parent)
            instance_variable_get(:"@#{attribute}") + parent.send(attribute)
          else
            instance_variable_get(:"@#{attribute}")
          end
        end
      end

      def initialize(parent: nil)
        super()

        @parent = parent
      end

      def value
        if @parent
          super + @parent.value
        else
          super
        end
      end

      private

      def __append__(val)
        super(val.to_s)
      end
    end
  end
end
