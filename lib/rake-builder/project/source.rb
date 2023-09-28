require_relative 'attributes'
require_relative '../utility/read_mf'
require_relative '../utility/clean'

module RakeBuilder
  class Project
    class Source
      include Rake::DSL
      include Attributes

      attr_path
      attr_tracked
      attr_dependencies

      def initialize(project_, parent_, path_)
        @project = project_
        @parent = parent_
        self.path = path_

        dependencies << path

        mf_path = @project.path_to_mf(path)
        dependencies << @project.rake_directory(mf_path.dirname)

        file mf_path.to_s => [*dependencies] do |t|
          @project.sh @project.gpp, *@parent.flags, '-c', t.source, '-M', '-MM', '-MF', t.name
        end

        o_path = @project.path_to_o(path)
        dependencies << @project.rake_directory(o_path.dirname)

        file o_path.to_s => [*dependencies, *@parent.dependencies, mf_path.to_s, *Utility.read_mf(mf_path)] do |t|
          @project.sh @project.gpp, *@parent.flags, '-c', t.source, '-o', t.name
        end
      end

      def as_object
        @project.path_to_o(path)
      end

      def clean
        mf_path = @project.path_to_mf(path)
        o_path = @project.path_to_o(path)

        Utility.clean(mf_path, o_path)
      end
    end
  end
end
