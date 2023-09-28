module RakeBuilder
  module Error
    class AmbigousResult < ArgumentError
      def initialize(message)
        super "AmbigousResult: '#{message}'"
      end
    end
  end
end
