module RakeBuilder
  module Error
    class UnsuportedType < ArgumentError
      def initialize(val)
        super "UnsuportedType: `#{val.class}'"
      end
    end
  end
end
