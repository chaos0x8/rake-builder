module RakeBuilder
  module Utility
    class CppStandard
      def initialize(arg)
        @str_value = nil
        @num_value = [0, 0.0]

        return if arg.nil?

        if arg.is_a?(CppStandard)
          @str_value = arg.str_value
          @num_value = arg.num_value
          return
        end

        @str_value = arg.to_s

        if m = @str_value.match(/^(\d+)$/)
          @num_value = if m[1] == '98'
                         [8, 0.0]
                       else
                         [m[1].to_i(10), 0.0]
                       end
        elsif m = @str_value.match(/^(\d)(\w)$/)
          @num_value = [m[1].to_i(10) * 10, -256.0 + m[2].unpack1('C')]
        else
          raise ArgumentError, "Cannot parse CppStandard `#{arg}'."
        end
      end

      def value
        @str_value
      end

      def <=>(other)
        if other.is_a?(CppStandard)
          @num_value <=> other.num_value
        elsif other.nil? || other.is_a?(String)
          self <=> CppStandard.new(other)
        else
          raise ArgumentError, "Cannot compare CppStandard with `#{other.class}'."
        end
      end

      def +(other)
        CppStandard.new(self) << other
      end

      def <<(other)
        nv = [self, CppStandard.new(other)].max
        @str_value = nv.str_value
        @num_value = nv.num_value

        self
      end

      protected

      attr_reader :str_value, :num_value
    end
  end
end
