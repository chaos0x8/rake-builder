require_relative 'utility'
require_relative 'project_file'

module C8
  class Project
    class PrecompiledHeader < C8::Project::File
      def initialize(path)
        super(path, target: ZeroTarget.new)
      end

      def make_rule(project)
        dirname = project.to_out(path, '').dirname

        mf_path = project.to_out(path, '.gch.mf')
        gch_path = path.sub_ext(path.extname + '.gch')
        @output_paths = [mf_path, gch_path]

        project.directory dirname

        make_rule_mf project, dirname, mf_path
        make_rule_gch project, dirname, mf_path, gch_path

        gch_path.to_s
      end

      private

      def make_rule_mf(project, dirname, mf_path)
        project.file mf_path.to_s => [path.to_s, dirname.to_s, *project.preconditions] do |t|
          C8.sh project.gpp, *project.flags, *@target.flags,
                '-x', 'c++-header', '-c', t.source, '-M', '-MM', '-MF', t.name,
                verbose: project.verbose, silent: project.silent
        end
      end

      def make_rule_gch(project, dirname, mf_path, gch_path)
        project.file gch_path.to_s => [path.to_s, dirname.to_s, mf_path.to_s, *C8::Utility.read_mf(mf_path),
                                       *project.preconditions] do |t|
          r, w = IO.pipe

          w.write %(#include "#{::File.expand_path(t.source)}"\n)
          w.close

          begin
            C8.sh project.gpp, *project.flags, *@target.flags,
                  '-x', 'c++-header', '-c', t.source, '-o', t.name, in: r,
                                                                    verbose: project.verbose, silent: project.silent,
                                                                    nonVerboseMessage: "#{project.gpp} #{t.source}"
          ensure
            r.close
          end
        end
      end
    end
  end
end
