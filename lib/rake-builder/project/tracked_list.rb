require_relative 'attributes'
require_relative 'project'

module RakeBuilder
  class Project
    class TrackedList
      include Rake::DSL
      include Attributes

      attr_path
      attr_dependencies

      def initialize(project_, path_, to_track_)
        @project = project_
        self.path = path_
        @to_track = to_track_

        dependencies << @project.rake_directory(path.dirname)

        FileUtils.rm path, verbose: true if path.exist? && read != @to_track.collect(&:to_s).to_a

        file path.to_s => [*dependencies] do |t|
          IO.write(t.name, @to_track.to_a.join("\n"))
        end

        path.to_s
      end

      def read
        if path.exist?
          IO.read(path).split("\n")
        else
          []
        end
      end
    end

    def tracked_list(path, to_track)
      TrackedList.new(self, path, to_track)
    end
  end
end
