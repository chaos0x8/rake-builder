module C8
  class Project
    class External
      class Error < RuntimeError
        def initialize(msg)
          super("External::Error #{msg}")
        end
      end

      attr_reader :path, :flags, :libs, :products

      def initialize(path, type, &block)
        @path = C8::Utility.to_pathname(path)
        @type = type
        @script = nil
        @flags = Flags.new
        @libs = []
        @products = Products.new

        instance_exec(self, &block)
      end

      def url(value)
        @url = value
      end

      def script(value)
        @script = value
      end

      def make_rule(project:)
        @products.each do |req|
          found = path.glob(File.join('**', req)).select do |fn|
            fn.to_s =~ /#{Regexp.quote(req.to_s)}$/
          end

          raise C8::Project::External::Error, "Requirement '#{req}' not found" if found.size == 0
          raise C8::Project::External::Error, "Requirement '#{req}' ambigous" if found.size > 1

          found.each do |fn|
            case req.extname
            when '.hpp', '.h'
              @flags << "-I#{fn.to_s.chomp(req.to_s)}"
            when '.a'
              @libs << fn.to_s
              @flags << "-L#{fn.to_s.chomp(req.to_s)}"
              @flags << "-l#{fn.basename.sub_ext('').sub(/^lib/, '')}"
            end
          end
        rescue C8::Project::External::Error
          retry if invoke
          raise
        end

        nil
      end

      private

      def invoke
        unless @invoked
          case @type
          when :submodule
            unless path.directory?
              C8.sh 'git', 'submodule', 'init', verbose: true
              C8.sh 'git', 'submodule', 'update', verbose: true
            end
            C8.sh "cd #{Shellwords.escape(path)} && #{@script.split("\n").join(' && ')}" if @script
          when :git
            C8.sh 'git', 'clone', @url, path.to_s unless path.directory?
            C8.sh "cd #{Shellwords.escape(path)} && #{@script.split("\n").join(' && ')}" if @script
          else
            raise ScriptError, "Unrecognized type '#{@type}'"
          end

          @invoked = true
        end
      end
    end
  end
end
