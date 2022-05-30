module C8
  class Project
    class Templates
      attr_reader :project

      def initialize(project:)
        @project = project
      end

      def cpp_include_directory(**opts, &block)
        instance_exec(self, &block) if block

        raise ArgumentError, 'Expected exactly one named argument!' unless opts.size == 1

        path = C8::Utility.to_pathname(opts.keys.first)
        items = case opts.values.first
                when Pathname
                  opts.values.first.children.uniq
                else
                  opts.values.first.uniq
                end
        workdir = @workdir || path.dirname

        project.file_generated path => items do
          include_paths = items.collect do |child|
            Pathname.new(child).relative_path_from(workdir)
          end.uniq

          C8.erb paths: include_paths do
            <<~INLINE
              #pragma once

              <%- paths.each do |path| -%>
              #include "<%= path %>"
              <%- end -%>
            INLINE
          end
        end
      end

      def method_missing(name, *args, **opts, &block)
        if m = name.to_s.match(/^(\w+)=$/) and args.size == 1 && opts.size == 0 && block.nil?
          instance_variable_set(:"@#{m[1]}", args.first)
        else
          super(*args, **opts, &block)
        end
      end
    end

    def templates
      Templates.new(project: self)
    end
  end
end
