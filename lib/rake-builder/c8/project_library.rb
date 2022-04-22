require_relative 'project_item'

module C8
  class Project
    class Library < Item
      def initialize(*args,  **opts, &block)
        super(*args, **opts, &block)

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
        project.file path.to_s => [dirname.to_s, cl_path.to_s, *C8::Utility.read_cl(cl_path),
                                   *project.preconditions] do |t|
          C8.sh project.ar, 'vsr', t.name, *object_files,
                verbose: project.verbose, silent: project.silent,
                nonVerboseMessage: "#{project.ar} #{t.name}"
        end

        path.to_s
      end
    end
  end
end
