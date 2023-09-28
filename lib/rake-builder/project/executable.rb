require_relative 'attributes'
require_relative '../utility/container_flag'
require_relative '../utility/container_source'
require_relative '../utility/clean'

module RakeBuilder
  class Project
    class Executable
      include Rake::DSL
      include Attributes

      attr_path
      attr_description
      attr_tracked
      attr_dependencies
      attr_container :flags, -> { Utility::ContainerFlagCompile.new(@project.flags) }
      attr_container :flags_link, -> { Utility::ContainerFlagLink.new(@project.flags_link) }
      attr_container :sources, Sources

      allow_pkg_config

      attr_reader :project

      def initialize(project_, path_)
        @project = project_
        self.path = path_

        yield self if block_given?

        dependencies << @project.rake_directory(path.dirname)
        dependencies << sources.as_objects

        rake_desc
        file path.to_s => [*dependencies] do |t|
          @project.sh @project.gpp, *flags, *sources.as_objects,
                      *flags_link, '-o', t.name
        end
      end

      def clean
        sources.each(&:clean)

        Utility.clean(path)
      end

      def link_static(lib)
        case lib
        when LibraryStatic
          dependencies << lib.dependencies << lib.path
          flags_link.link_static lib.path
        when ::String, ::Pathname
          dependencies << lib
          flags_link.link_static lib
        else
          raise Error::UnsuportedType, lib
        end
      end

      def link_dynamic(lib)
        case lib
        when ::String, ::Pathname
          dependencies << lib
          flags_link.link_dynamic lib
        else
          raise Error::UnsuportedType, lib
        end
      end
    end

    def executable(path, &block)
      Executable.new(self, path) do |exe|
        @externals.each do |ext|
          exe.flags << ext.provided_flags
          exe.flags_link << ext.provided_flags_link
        end

        @libraries_static.each do |lib|
          exe.dependencies << lib.dependencies << lib.path
          exe.flags_link << lib.path
        end

        exe.dependencies << @generated_files_targets

        block.call(exe) if block
      end.tap do |exe|
        @executables << exe
      end
    end
  end
end
