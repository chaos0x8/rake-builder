require_relative 'common'

module RakeBuilder
  module Utility
    class Container
      include Enumerable

      def initialize(value = nil, convert: nil, is_tail: nil)
        @value = []

        unless is_tail
          @on_tail = Container.new(convert: convert, is_tail: true)

          define_singleton_method :on_tail do
            instance_variable_get(:@on_tail)
          end
        end

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
        elsif value.is_a? Container
          value.each do |v|
            self << v
          end

          if value.respond_to?(:on_tail) && respond_to?(:on_tail)
            value.on_tail.each do |v|
              on_tail << v
            end
          end
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

        self
      end

      def delete(value)
        if value.nil?
          nil
        elsif value.respond_to? :each
          value.each do |v|
            delete v
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
        to_a.each(&block)
      end

      def size
        to_a.size
      end

      def to_a
        if instance_variable_defined?(:@on_tail)
          self.class.new.tap do |c|
            c << @value
            c.delete @on_tail
            c << @on_tail
          end.instance_variable_get(:@value).uniq
        else
          @value.uniq
        end
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
