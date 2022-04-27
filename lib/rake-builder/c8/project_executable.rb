require_relative 'project_item'

module C8
  class Project
    class Executable < Item
      attr_reader :libs, :link_flags

      def initialize(*args,  **opts, &block)
        super(*args, **opts, &block)

        @libs = []
        @link_flags = Flags.new

        instance_exec(self, &block)
      end

      def make_rule(project:)
        object_files = sources.collect do |src|
          src.make_rule project
        end

        cl_path = project.to_out(path, '.cl')
        cl_dirname = cl_path.dirname

        project.directory cl_dirname

        project.file cl_path.to_s => [*object_files, cl_dirname.to_s] do |t|
          IO.write(t.name, object_files.join("\n"))
        end

        project.directory dirname

        project.method(:desc).super_method.call @desc
        project.file path.to_s => [dirname.to_s, cl_path.to_s, *C8::Utility.read_cl(cl_path), *libs,
                                   *project.preconditions] do |t|
          C8.sh project.gpp, *project.flags, *flags, *object_files, *link_flags, *project.link_flags,
                '-o', t.name,
                verbose: project.verbose, silent: project.silent,
                nonVerboseMessage: "#{project.gpp} #{t.name}"
        end

        path.to_s
      end

      def pkg_config pkg
        @flags << C8::Utility.pkg_config('--cflags', pkg)
        @link_flags << C8::Utility.pkg_config('--libs', pkg)
      end

      def link(lib)
        case lib
        when C8::Project::External
          lib.libs.each do |v|
            libs << v
          end
          flags << lib.flags
          link_flags << lib.link_flags
        when C8::Project::Library
          libs << lib.path.to_s
          link_flags << "-L#{lib.path.dirname}"
          link_flags << "-l#{lib.path.basename.sub_ext('').sub(/^lib/, '')}"
        when String, Pathname
          libs << lib.to_s
        else
          raise ScriptError, "Unknown type to link '#{lib.class}'"
        end
      end
    end
  end
end
