require_relative 'project_source'

module C8
  class Project
    class Sources
      include Enumerable

      def initialize(target:)
        @files = []
        @target = target
      end

      def <<(value)
        case value
        when Array
          value.each do |v|
            self << v
          end
        when Source
          self << value
        else
          @files << Source.new(value, target: @target)
        end
      end

      def each(&block)
        @files.each(&block)
      end

      def size
        @files.size
      end
    end
  end
end
