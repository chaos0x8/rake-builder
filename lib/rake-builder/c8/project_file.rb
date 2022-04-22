require_relative 'utility'

module C8
  class Project
    class File
      attr_reader :path

      def initialize(path)
        @path = C8::Utility.to_pathname(path)
      end

      def make_rule(project)
        dirname = project.to_out(path, '').dirname

        mf_path = project.to_out(path, '.mf')
        o_path = project.to_out(path, '.o')

        project.directory dirname

        project.file mf_path.to_s => [path.to_s, dirname.to_s, *project.preconditions] do |t|
          C8.sh project.gpp, *project.flags,
                '-c', t.source, '-M', '-MM', '-MF', t.name,
                verbose: project.verbose, silent: project.silent
        end

        project.file o_path.to_s => [path.to_s, dirname.to_s, mf_path.to_s, *C8::Utility.read_mf(mf_path),
                                     *project.preconditions] do |t|
          C8.sh project.gpp, *project.flags,
                '-c', t.source, '-o', t.name,
                verbose: project.verbose, silent: project.silent,
                nonVerboseMessage: "#{project.gpp} #{t.source}"
        end

        o_path.to_s
      end
    end
  end
end
