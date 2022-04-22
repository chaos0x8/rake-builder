require_relative 'utility'
require_relative 'project_flags'
require_relative 'project_sources'

module C8
  class Project
    class Item
      attr_reader :path, :sources, :flags

      def initialize(path)
        @path = C8::Utility.to_pathname(path)
        @desc = nil
        @sources = Sources.new
        @flags = Flags.new
      end

      def dirname
        path.dirname
      end

      def desc(value)
        @desc = value
      end
    end
  end
end
