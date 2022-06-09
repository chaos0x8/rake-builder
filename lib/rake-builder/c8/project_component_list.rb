require_relative 'project_dsl'
require_relative 'project_containers'

module C8
  class Project
    class ComponentList
      include Project::DSL

      attr_reader :path

      project_attr_reader :sources, default: -> { StringContainer.new }

      def initialize(path, **opts, &block)
        @path = C8::Utility.to_pathname(path)

        initialize_project_attrs(**opts)

        instance_exec(self, &block) if block_given?
      end

      def make_rule(project:)
        project.directory dirname

        FileUtils.rm path, verbose: true if !(read == sources.to_a) && path.exist?

        project.file path.to_s => [*sources, dirname.to_s] do |t|
          IO.write(t.name, sources.to_a.join("\n"))
        end

        path.to_s
      end

      def dirname
        path.dirname
      end

      def read
        if path.exist?
          IO.read(path).split("\n")
        else
          []
        end
      end
    end
  end
end
