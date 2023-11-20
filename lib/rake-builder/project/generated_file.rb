require_relative '../utility/container_string'
require_relative '../utility/to_pathname'
require_relative '../c8/erb'
require_relative 'attributes'
require_relative 'project'
require_relative 'global'
require_relative 'tracked_list'
require_relative '../c8/tasks'
require 'securerandom'

module RakeBuilder
  class Project
    class GeneratedFile
      include Rake::DSL
      include Attributes

      attr_path
      attr_description
      attr_erb
      attr_tracked
      attr_dependencies

      def initialize(project_, path_)
        @project = project_
        @script = nil
        self.path = path_

        yield(self) if block_given?

        dependencies << @project.rake_directory(@path.dirname) if @path.dirname != Pathname('.')
        dependencies << @project.tracked_list(@project.path_to_tl(path), tracked)

        rake_desc
        file path.to_s => [*dependencies] do |t|
          if @script
            @script.call(t.name, @erb.nil? ? nil : C8.erb_eval(@erb))
          else
            IO.write(t.name, C8.erb_eval(@erb))
          end
        end
      end

      def script(&block)
        @script = block
      end

      def requirements
        Utility::StringContainer.new.tap do |c|
          c << dependencies
        end
      end

      def clean
        tl_path = @project.path_to_tl(path)

        Utility.clean(tl_path, path)
      end
    end

    def generated_file(path, &block)
      GeneratedFile.new(self, path, &block).tap do |file|
        @generated_files << file

        namespace :generated do
          name = RakeBuilder.random_task

          C8.phony name => path

          @generated_files_targets << "generated:#{name}"
        end
      end
    end
  end
end
