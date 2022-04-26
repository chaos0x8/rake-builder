require_relative 'utility'

module C8
  class Project
    class Container
      include Enumerable

      def initialize(&block)
        @value = []
        @convert = block
      end

      def <<(value)
        case value
        when Array
          value.each do |v|
            self << v
          end
        else
          @value << if respond_to? :convert
                      convert(value)
                    else
                      value
                    end
        end
      end

      def each(&block)
        @value.uniq.each(&block)
      end

      def size
        @value.uniq.size
      end

      def to_a
        @value.uniq
      end
    end

    class Flags < Container
    end

    class Products < Container
      def convert(v)
        C8::Utility.to_pathname(v)
      end
    end
  end
end
