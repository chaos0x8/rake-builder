require_relative 'base'
require_relative '../error'

module RakeBuilder
  module DSL
    class External
      class Error < RakeBuilder::Error
      end

      include Rake::DSL
      include DSL::Base

      attr_reader :type, :url
      attr_accessor :script

      def_attr :products, Utility::Paths
      def_attr :flags, Utility::Flags
      def_attr :link_flags, Utility::Flags

      def initialize(p, type)
        @path = Utility.to_pathname(p)
        @type = type
        @url = nil
        @script = nil
        @invoked = false

        yield(self) if block_given?

        prepare
      end

      def url=(value)
        @url = Utility.to_pathname(value)
      end

      private

      def prepare
        products.each do |req|
          found = @path.glob(::File.join('**', req)).select do |fn|
            fn.to_s =~ /#{Regexp.quote(req.to_s)}$/
          end

          raise RakeBuilder::DSL::External::Error, "Requirement '#{req}' not found" if found.size == 0
          raise RakeBuilder::DSL::External::Error, "Requirement '#{req}' ambigous" if found.size > 1

          found.each do |fn|
            case req.extname
            when '.hpp', '.h'
              flags << "-I#{fn.to_s.chomp(req.to_s).chomp('/')}"
            when '.so'
              #              libs << fn.to_s
              link_flags << "-Wl,-rpath=#{fn.dirname}"
              link_flags << "-L#{fn.dirname}"
              link_flags << "-l#{fn.basename.sub_ext('').sub(/^lib/, '')}"
            when '.a'
              #              libs << fn.to_s
              link_flags << "-L#{fn.dirname}"
              link_flags << "-l#{fn.basename.sub_ext('').sub(/^lib/, '')}"
            end
          end
        rescue RakeBuilder::DSL::External::Error => e
          retry if invoke
          raise
        end

        nil
      end

      def invoke
        unless @invoked
          case @type
          when :submodule
            unless @path.directory?
              builder.sh 'git', 'submodule', 'init', verbose: true
              builder.sh 'git', 'submodule', 'update', verbose: true
            end
            builder.script <<~SCRIPT
              cd #{Shellwords.escape(@path)}
              #{@script}
            SCRIPT
          when :git
            builder.sh 'git', 'clone', @url.to_s, @path.to_s unless @path.directory?
            builder.script <<~SCRIPT
              cd #{Shellwords.escape(@path)}
              #{@script}
            SCRIPT
          when :wget
            archive = project.to_out(@url.basename, '')
            begin
              builder.sh 'wget', @url.to_s, '-O', archive.to_s
              builder.sh 'tar', '-C', @path.dirname.to_s, '-zxf', archive.to_s
              builder.script <<~SCRIPT
                cd #{Shellwords.escape(@path)}
                #{@script}
              SCRIPT
            ensure
              FileUtils.rm archive, verbose: true if archive.exist?
            end
          else
            raise ScriptError, "Unrecognized type '#{@type}'"
          end

          @invoked = true
        end
      end
    end

    def external(path, type, &block)
      External.new(path, type, &block)
    end
  end
end
