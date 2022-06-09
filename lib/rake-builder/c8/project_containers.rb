require_relative 'utility'

module C8
  class Project
    class Container
      include Enumerable

      def initialize(convert: nil)
        @value = []

        if convert
          @convert = convert

          define_singleton_method :convert do |v|
            instance_exec(v, &@convert)
          end
        end
      end

      def <<(value)
        case value
        when Array, Container
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

    class StringContainer < Container
      def initialize
        super(convert: proc do |v|
          if v.respond_to? :path
            v.path.to_s
          else
            v.to_s
          end
        end)
      end
    end

    class Products < Container
      def initialize
        super convert: ->(v) { C8::Utility.to_pathname(v) }
      end
    end
  end
end
