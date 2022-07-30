require_relative '../utility/common'

module RakeBuilder
  module DSL
    class Source
      include Rake::DSL
      include DSL::Base

      attr_reader :path, :target

      def initialize(p, t)
        @path = Utility.to_pathname(p)
        @target = t

        depend path

        mf_path = builder.path_to_mf(path)
        depend builder.directory(mf_path.dirname)

        file mf_path.to_s => [*dependencies] do |t|
          builder.sh builder.gpp, *target.flags, '-c', t.source, '-M', '-MM', '-MF', t.name
        end

        o_path = builder.path_to_o(path)
        depend builder.directory(o_path.dirname)

        file o_path.to_s => [*dependencies, mf_path.to_s, *Utility.read_mf(mf_path)] do |t|
          builder.sh builder.gpp, *target.flags, '-c', t.source, '-o', t.name
        end
      end
    end

    class Sources
      include Enumerable

      def initialize(target)
        @files = []
        @target = target
      end

      def <<(value)
        case value
        when Array
          value.each do |v|
            self << v
          end
        when Source
          self << value
        else
          @files << Source.new(value, @target)
        end
      end

      def each(&block)
        @files.each(&block)
      end

      def size
        @files.size
      end
    end
  end
end
