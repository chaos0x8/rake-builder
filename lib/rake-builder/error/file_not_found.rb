module RakeBuilder
  module Error
    class FileNotFound < ArgumentError
      def initialize(rel_path, workdir)
        super "FileNotFound: Cannot find file '#{rel_path}' in '#{workdir}'"
      end
    end
  end
end
