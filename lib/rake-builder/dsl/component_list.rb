require_relative '../utility/containers'
require_relative 'base'

module RakeBuilder
  module DSL
    class ComponentList
      include Rake::DSL
      include DSL::Base

      attr_reader :path

      def initialize(p, to_track)
        @path = Utility.to_pathname(p)
        track to_track

        yield(self) if block_given?

        depend builder.directory(path.dirname)

        FileUtils.rm path, verbose: true if path.exist? && read != tracked.collect(&:to_s).to_a

        file path.to_s => [*dependencies] do |t|
          IO.write(t.name, tracked.to_a.join("\n"))
        end

        path.to_s
      end

      def read
        if path.exist?
          IO.read(path).split("\n")
        else
          []
        end
      end
    end

    def component_list(path, to_track, &block)
      ComponentList.new(path, to_track, &block)
    end
  end
end
