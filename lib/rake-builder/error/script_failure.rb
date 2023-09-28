module RakeBuilder
  module Error
    class ScriptFailure < ArgumentError
      def initialize
        super 'ScriptFailure'
      end
    end
  end
end
