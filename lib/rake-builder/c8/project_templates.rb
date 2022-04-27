module C8
  class Project
    class Templates
      attr_reader :project

      def initialize(project:)
        @project = project
      end

      def cpp_include_directory(**opts, &block)
        instance_exec(self, &block) if block

        if opts.size > 0
          path = C8::Utility.to_pathname(opts.keys.first)
          items = case opts.values.first
                  when Pathname
                    opts.values.first.children
                  else
                    opts.values.first
                  end
        end

        project.file_generated path => items do
          C8.erb workdir: @workdir || path.dirname,
                 items: items do
            <<~INLINE
              #pragma once

              <%- items.each do |child| -%>
              #include "<%= Pathname.new(child).relative_path_from(workdir) %>"
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
