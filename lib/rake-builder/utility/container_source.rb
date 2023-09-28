require_relative 'container'
require_relative '../project/source'

module RakeBuilder
  class Project
    class Sources < Utility::Container
      include Enumerable

      def initialize(parent_:)
        super()
        @parent = parent_
      end

      def as_objects
        @value.collect { |v| v.as_object.to_s }.to_a
      end

      private

      def append(val)
        super Project::Source.new(@parent.project, @parent, val)
      end
    end
  end
end
