require_relative 'common'

module RakeBuilder
  module Utility
    class Container
      include Enumerable

      def initialize(value = nil, convert: nil)
        @value = []

        if convert
          @convert = convert

          define_singleton_method :convert do |v|
            instance_exec(v, &@convert)
          end
        end

        self << value
      end

      def <<(value)
        if value.nil?
          nil
        elsif value.respond_to? :each
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

      def delete(value)
        if value.nil?
          nil
        elsif value.respond_to? :each
          value.each do |v|
            self << v
          end
        else
          to_erase = if respond_to? :convert
                       convert(value)
                     else
                       value
                     end
          @value.delete(to_erase)
        end
      end

      def -(other)
        raise ArgumentError, "Expected #{self.class}, but got #{other.class}" unless other.instance_of?(self.class)

        StringContainer.new.tap do |result|
          result << (each.to_a - other.each.to_a)
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
      def initialize(value = nil)
        super(value, convert: proc do |v|
          if v.respond_to? :path
            v.path.to_s
          else
            v.to_s
          end
        end)
      end
    end

    class Paths < Container
      def initialize(value = nil)
        super value, convert: ->(v) { Utility.to_pathname(v) }
      end
    end
  end
end
