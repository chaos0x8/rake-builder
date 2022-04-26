require_relative 'utility'

module C8
  class Project
    class File
      attr_reader :path

      def initialize(path, target:)
        @path = C8::Utility.to_pathname(path)
        @target = target
      end

      def make_rule(project)
        dirname = project.to_out(path, '').dirname

        mf_path = project.to_out(path, '.mf')
        o_path = project.to_out(path, '.o')

        project.directory dirname

        make_rule_mf project, dirname, mf_path
        make_rule_o project, dirname, mf_path, o_path

        o_path.to_s
      end

      private

      def make_rule_mf(project, dirname, mf_path)
        project.file mf_path.to_s => [path.to_s, dirname.to_s, *project.preconditions] do |t|
          C8.sh project.gpp, *project.flags, *@target.flags,
                '-c', t.source, '-M', '-MM', '-MF', t.name,
                verbose: project.verbose, silent: project.silent
        end
      end
    end
  end
end
