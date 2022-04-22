module C8
  class Project
    class Flags
      def initialize
        @flags = []
      end

      def <<(value)
        case value
        when Array
          value.each do |v|
            self << v
          end
        else
          @flags << value
        end
      end

      def to_a
        @flags
      end
    end
  end
end
