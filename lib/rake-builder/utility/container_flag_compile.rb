require_relative 'container_flag'

module RakeBuilder
  module Utility
    class ContainerFlagCompile < ContainerFlag
      attr_reader :std

      def initialize(parent_flags_ = nil)
        super(parent_flags_)
        @std = 0
      end

      def to_a
        if @parent_flags
          (std_flag + @parent_flags.instance_variable_get(:@value) + @value).collect(&:to_s).uniq
        else
          (std_flag + @value).collect(&:to_s).uniq
        end
      end

      def std=(val)
        case val
        when Integer
          @std = val
        when String
          raise ArgumentError, "Cannot convert `#{val}' to std, expected `Integer'" unless val.match(/^\d+$/)

          @std = val.to_i(10)
        else
          self.std = val.to_s
        end
      end

      private

      def std_flag
        std_value = [@std]
        std_value << @parent_flags.std if @parent_flags

        if std_value.max != 0
          %W[--std=c++#{std_value.max}]
        else
          %w[]
        end
      end

      def append(val)
        case val
        when String
          if m = val.match(/^--std=c\+\+(\d+)$/) || val.match(/^-std=c\+\+(\d+)$/)
            self.std = m[1]
          else
            super(val)
          end
        else
          super(val)
        end
      end
    end
  end
end
