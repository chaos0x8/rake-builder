module RakeBuilder
  module Error
    class PkgConfigFailure < RuntimeError
      def initialize(out)
        super out
      end
    end
  end
end
