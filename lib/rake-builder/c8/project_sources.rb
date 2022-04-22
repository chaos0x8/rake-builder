require_relative 'project_file'

module C8
  class Project
    class Sources
      include Enumerable

      def initialize
        @files = []
      end

      def <<(value)
        case value
        when Array
          value.each do |v|
            self << v
          end
        when File
          self << value
        else
          @files << File.new(value)
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
