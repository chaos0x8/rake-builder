require_relative 'base'
require_relative 'sources'

module RakeBuilder
  module DSL
    class Library
      include Rake::DSL
      include DSL::Base

      attr_reader :path
      attr_accessor :description

      def_attr :flags, Utility::Flags
      def_attr :sources, -> { Sources.new(self) }
      def_clean :requirements, :path

      def initialize(p)
        @path = Utility.to_pathname(p)

        yield(self) if block_given?

        depend builder.directory(path.dirname)
        depend component_list(builder.path_to_cl(path), sources)

        objects = sources.collect { |x| builder.path_to_o(x).to_s }

        desc @description if @description
        file path.to_s => requirements.to_a do |t|
          builder.sh builder.ar, 'vsr', t.name, *objects
        end
      end

      def requirements
        Utility::StringContainer.new.tap do |c|
          c << dependencies
          c << sources.collect { |x| builder.path_to_o(x) }
          c << sources.collect { |x| builder.path_to_mf(x) }
        end
      end
    end

    def library(path, &block)
      Library.new(path, &block)
    end
  end
end
