require 'erb'

require_relative 'base'
require_relative 'component_list'

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
          IO.write(t.name, erb_eval)
        end
      end

      def requirements
        Utility::StringContainer.new.tap do |c|
          c << dependencies
        end
      end

      def_clean :path

      private

      def erb_eval
        case @erb
        when Proc
          erb = ERB.new(@erb.call, trim_mode: '-')
          erb.result @erb.binding
        when String
          erb = ERB.new(@erb, trim_mode: '-')
          erb.result RakeBuilder::DSL::GeneratedFile.empty_binding
        else
          raise ArgumentError, "Expected `Proc` or `String` but got: #{@erb.class}"
        end
      end

      def self.empty_binding
        binding
      end
    end

    def generated_file(path, &block)
      GeneratedFile.new(path, &block)
    end
  end
end
