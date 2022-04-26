require_relative 'utility'
require_relative 'project_file'

module C8
  class Project
    class Header < C8::Project::File
      private

      def make_rule_o(project, dirname, mf_path, o_path)
        project.file o_path.to_s => [path.to_s, dirname.to_s, mf_path.to_s, *C8::Utility.read_mf(mf_path),
                                     *project.preconditions] do |t|
          r, w = IO.pipe

          w.write %(#include "#{::File.expand_path(t.source)}"\n)
          w.close

          begin
            C8.sh project.gpp, *project.flags,
                  '-x', 'c++', '-c', '-', '-o', o_path.to_s, in: r,
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
