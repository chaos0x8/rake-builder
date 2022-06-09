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

        cl = ComponentList.new project.to_out(path, '.cl')
        cl.sources << sources.to_a
        cl.make_rule project: project

        project.directory dirname

        project.desc @description if @description
        project.file path.to_s => [dirname.to_s, cl.path.to_s, *object_files,
                                   *project.preconditions] do |t|
          C8.sh project.ar, 'vsr', t.name, *object_files,
                verbose: project.verbose, silent: project.silent,
                nonVerboseMessage: "#{project.ar} #{t.name}"
        end

        path.to_s
      end

      def link(ext)
        case ext
        when C8::Project::External
          flags << ext.flags
        else
          raise ScriptError, "Unknown type to link '#{ext.class}'"
        end
      end
    end
  end
end
