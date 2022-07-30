require_relative 'base'
require_relative 'sources'

module RakeBuilder
  module DSL
    class Configure
      include Rake::DSL
      include DSL::Base

      attr_reader :name
      attr_accessor :description

      def initialize(n)
        @name = n
        @commands = []

        yield(self) if block_given?

        desc @description if @description
        C8.phony @name do
          @commands.each(&:call)
        end
      end

      def apt_install(*args)
        @commands.push(proc do
          pkgs = Utility::StringContainer.new(args)
          RakeBuilder.apt_install(*pkgs)
        end)
      end
    end

    def configure(name, &block)
      Configure.new(name, &block)
    end
  end
end
