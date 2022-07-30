require_relative 'base'
require_relative 'sources'

module RakeBuilder
  module DSL
    class Header
      include Rake::DSL
      include DSL::Base

      attr_reader :path

      def_attr :flags, Utility::Flags
      def_clean :requirements

      def initialize(p)
        @path = Utility.to_pathname(p)
        @requirements = Utility::StringContainer.new

        yield(self) if block_given?

        depend path

        mf_path = builder.path_to_mf(path)
        depend builder.directory(mf_path.dirname)

        file mf_path.to_s => [*dependencies] do |t|
          builder.sh builder.gpp, *flags, '-c', t.source, '-M', '-MM', '-MF', t.name
        end

        o_path = builder.path_to_o(path)
        depend builder.directory(o_path.dirname)

        file o_path.to_s => [*dependencies, mf_path.to_s, *Utility.read_mf(mf_path)] do |t|
          r, w = IO.pipe

          w.write %(#include "#{::File.expand_path(t.source)}"\n)
          w.close

          begin
            builder.sh builder.gpp, *flags, '-x', 'c++', '-c', '-', '-o', t.name, in: r
          ensure
            r.close
          end
        end
      end

      def requirements
        Utility::StringContainer.new.tap do |c|
          c << builder.path_to_mf(path)
          c << builder.path_to_o(path)
        end
      end
    end

    def header(path, &block)
      Header.new(path, &block)
    end
  end
end
