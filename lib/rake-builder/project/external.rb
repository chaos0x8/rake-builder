require_relative 'attributes'
require_relative '../error/unsuported_type'
require_relative '../error/ambigous_result'
require_relative '../error/file_not_found'
require_relative '../utility/to_pathname'
require_relative '../utility/container_flag_compile'
require_relative '../utility/container_flag_link'
require 'set'

module RakeBuilder
  class Project
    class External
      include Rake::DSL
      include Attributes

      attr_path
      attr_container :provided_flags, Utility::ContainerFlagCompile
      attr_container :provided_flags_link, Utility::ContainerFlagLink

      attr_accessor :command_compile, :command_clean
      attr_reader :project

      def initialize(project_, path_)
        @project = project_
        self.path = path_
        @flags = Set.new

        yield self if block_given?
      end

      def compile
        return if @flags.include?(:compiled)

        @flags << :compiled
        exec_command command_compile
      end

      def clean
        exec_command command_clean
      end

      def provide_include(rel_path, work_dir: nil)
        result = glob(rel_path, work_dir)

        include_dir = result.to_s.chomp(rel_path.to_s)

        provided_flags << "-I#{include_dir}"

        nil
      end

      def provide_library_static(rel_path, work_dir: nil)
        provided_flags_link << glob(rel_path, work_dir)

        nil
      end

      def provide_library_dynamic(rel_path, work_dir: nil)
        result = glob(rel_path, work_dir)

        library_dir = result.dirname
        library_short_name = result.basename.sub_ext('').sub(/^lib/, '')

        provided_flags_link << %W[-Wl,-rpath=#{library_dir} -L#{library_dir} -l#{library_short_name}]

        nil
      end

      private

      def glob(rel_path, work_dir)
        rel_path = Utility.to_pathname(rel_path)
        work_dir = Utility.to_pathname(work_dir || path)

        files = work_dir.glob(Pathname.new('**').join(rel_path))
        raise Error::FileNotFound.new(rel_path, work_dir) if files.empty?
        raise Error::AmbigousResult, "Expected 1 file but got #{files.size}" unless files.size == 1

        files.first
      rescue Error::FileNotFound
        raise if @flags.include?(:compiled)

        compile
        retry
      end

      def exec_command(command_)
        case command_
        when Proc
          ret = command_.call
          case ret
          when String
            @project.sh_script <<~SCRIPT
              cd #{Shellwords.escape(path)}
              #{ret}
            SCRIPT
          else
            raise Error::UnsuportedType, ret
          end
        when String
          @project.sh_script <<~SCRIPT
            cd #{Shellwords.escape(path)}
            #{command_}
          SCRIPT
        else
          raise Error::UnsuportedType, command_
        end

        nil
      end
    end

    def external(path, &block)
      External.new(self, path, &block).tap do |ext|
        @externals << ext
      end
    end
  end
end
