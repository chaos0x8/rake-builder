require_relative 'project_dsl'

module C8
  class Project
    class External
      class Error < RuntimeError
        def initialize(msg)
          super("External::Error #{msg}")
        end
      end

      include Project::DSL

      attr_reader :path, :libs

      project_attr_reader :flags, default: -> { Flags.new }
      project_attr_reader :link_flags, default: -> { Flags.new }
      project_attr_reader :products, default: -> { Products.new }

      def initialize(path, type, &block)
        @path = C8::Utility.to_pathname(path)
        @type = type
        @script = nil
        @libs = []

        initialize_project_attrs

        instance_exec(self, &block)
      end

      def url(value)
        @url = C8::Utility.to_pathname(value)
      end

      def script(value)
        @script = value
      end

      def make_rule(project:)
        @products.each do |req|
          found = path.glob(::File.join('**', req)).select do |fn|
            fn.to_s =~ /#{Regexp.quote(req.to_s)}$/
          end

          raise C8::Project::External::Error, "Requirement '#{req}' not found" if found.size == 0
          raise C8::Project::External::Error, "Requirement '#{req}' ambigous" if found.size > 1

          found.each do |fn|
            case req.extname
            when '.hpp', '.h'
              @flags << "-I#{fn.to_s.chomp(req.to_s)}"
            when '.so'
              @libs << fn.to_s
              @link_flags << "-Wl,-rpath=#{fn.dirname}"
              @link_flags << "-L#{fn.dirname}"
              @link_flags << "-l#{fn.basename.sub_ext('').sub(/^lib/, '')}"
            when '.a'
              @libs << fn.to_s
              @link_flags << "-L#{fn.dirname}"
              @link_flags << "-l#{fn.basename.sub_ext('').sub(/^lib/, '')}"
            end
          end
        rescue C8::Project::External::Error
          retry if invoke project
          raise
        end

        nil
      end

      private

      def invoke(project)
        unless @invoked
          case @type
          when :submodule
            unless path.directory?
              C8.sh 'git', 'submodule', 'init', verbose: true
              C8.sh 'git', 'submodule', 'update', verbose: true
            end
            C8.sh "cd #{Shellwords.escape(path)} && #{@script.split("\n").join(' && ')}" if @script
          when :git
            C8.sh 'git', 'clone', @url.to_s, path.to_s unless path.directory?
            C8.sh "cd #{Shellwords.escape(path)} && #{@script.split("\n").join(' && ')}" if @script
          when :wget
            archive = project.to_out(@url.basename, '')
            begin
              C8.sh 'wget', @url.to_s, '-O', archive.to_s
              C8.sh 'tar', '-C', path.dirname.to_s, '-zxf', archive.to_s
              C8.script <<~SCRIPT
                cd #{Shellwords.escape(path)}
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
  end
end
