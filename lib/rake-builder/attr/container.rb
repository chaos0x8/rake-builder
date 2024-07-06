require_relative '../project/pkg_config'

require 'forwardable'
require 'pathname'

module RakeBuilder
  module Attr
    class Container
      include Enumerable
      extend Forwardable

      attr_reader :value

      def initialize
        @value = []
      end

      def <<(val)
        case val
        when ::Array
          val.each do |v|
            self << v
          end
        when ::String, ::Pathname, ::Symbol,
             PkgConfig
          __append__(val)
        when Container
          val.each do |v|
            self << v
          end
        when NilClass
          nil
        else
          raise Error::UnsuportedType, val
        end

        self
      end

      def +(other)
        self.class.new.tap do |result|
          if instance_variables == other.instance_variables &&
             (instance_variables.sort == %i[@value @parent].sort || instance_variables.sort == %i[@value].sort)
            result.instance_variable_set(:@value, value)
            result << other.value
          else
            raise "Cannot execute #{self.class} + #{other.class}. Types are not compatible"
          end
        end
      end

      def to_a
        value
      end

      def_delegators :value, :each, :size, :empty?

      private

      def __append__(val)
        @value.delete(val) if @value.include?(val)
        @value << val
      end
    end
  end
end
