require_relative 'utility'
require_relative 'project_containers'
require_relative 'project_sources'
require_relative 'project_dsl'

module C8
  class Project
    class Item
      include Project::DSL

      attr_reader :path

      project_attr_reader :flags, default: -> { Flags.new }
      project_attr_reader :sources, default: -> { Sources.new(target: self) }
      project_attr_writer :description

      def initialize(path, **opts)
        @path = C8::Utility.to_pathname(path)

        initialize_project_attrs(**opts)
      end

      def dirname
        path.dirname
      end

      def output_paths
        [path] + sources.reduce([]) do |sum, src|
          sum + src.output_paths
        end
      end
    end
  end
end
