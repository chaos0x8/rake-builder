require_relative 'attributes'
require_relative '../utility/container_flag'
require_relative '../utility/container_source'
require_relative '../utility/clean'

module RakeBuilder
  class Project
    class LibraryStatic
      include Rake::DSL
      include Attributes

      attr_path
      attr_description
      attr_tracked
      attr_dependencies
      attr_container :flags, -> { Utility::ContainerFlagCompile.new(@project.flags) }
      attr_container :sources, Sources

      allow_pkg_config

      attr_reader :project

      def initialize(project_, path_)
        @project = project_
        self.path = path_

        yield self if block_given?

        dependencies << @project.rake_directory(path.dirname) if path.dirname != Pathname('.')
        dependencies << sources.as_objects

        rake_desc
        file path.to_s => [*dependencies] do |t|
          @project.sh @project.ar, 'vsr', t.name, *sources.as_objects
        end
      end

      def clean
        sources.each(&:clean)

        Utility.clean(path)
      end
    end

    def library_static(path, &block)
      LibraryStatic.new(self, path, &block).tap do |lib|
        @externals.each do |ext|
          lib.flags << ext.provided_flags
        end

        lib.dependencies << @generated_files_targets

        @libraries_static << lib
      end
    end
  end
end
