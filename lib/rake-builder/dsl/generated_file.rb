require 'erb'

require_relative 'base'
require_relative 'component_list'
require_relative '../c8/erb'

module RakeBuilder
  module DSL
    class GeneratedFile
      include Rake::DSL
      include DSL::Base

      attr_reader :path
      attr_accessor :description, :erb

      def initialize(p)
        @path = Utility.to_pathname(p)

        yield(self) if block_given?

        depend builder.directory(path.dirname)
        depend component_list(builder.path_to_cl(path), tracked)

        desc @description if @description
        file path.to_s => [*dependencies] do |t|
          IO.write(t.name, C8.erb_eval(@erb))
        end
      end

      def requirements
        Utility::StringContainer.new.tap do |c|
          c << dependencies
        end
      end

      def_clean :path
    end

    def generated_file(path, &block)
      GeneratedFile.new(path, &block)
    end
  end
end
