module RakeBuilder
  module Trackable
    def self.extended(mod)
      mod.attribute :track, Attr::PathContainer
      mod.attr_reader :tl_path
      mod.define_method :__init_track__ do |*args|
        track << args

        return if track.empty?

        @tl_path = @project.path_to_tl(path)
        tl_path_dir = @project.directory(@tl_path.dirname)

        file tl_path.to_s => [*track, tl_path_dir] do |t|
          IO.write(t.name, track.to_a.join("\n"))
        end
      end
    end
  end
end
