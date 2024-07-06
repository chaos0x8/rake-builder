require_relative 'mixin/attributes'
require_relative 'mixin/cleanable'

module RakeBuilder
  class Source
    include Rake::DSL
    extend Attributes
    extend Cleanable

    attribute :path, Attr::Path
    attribute :flags_compile, Attr::FlagsCompile, opts: { parent: :@parent }
    attribute :dependencies, Attr::StringContainer, assignable: false
    attribute :depend, Attr::StringContainer, opts: { parent: :@parent }

    attribute_collect :collect_dependencies, Attr::StringContainer,
                      self: %i[@mf_path @o_path @depend]

    define_clean :mf_path, :o_path

    attr_reader :mf_path, :o_path

    def initialize(project, parent, path:, **opts)
      @project = project
      @parent = parent

      __init_attributes__(path: path, **opts)
      __init_target__
    end

    def __init_target__
      dependencies << path

      @mf_path = @project.path_to_mf(path)
      dependencies << @project.directory(mf_path.dirname)

      file mf_path.to_s => [*dependencies, *depend] do |t|
        @project.cmd_compile(*flags_compile, '-c', t.source, '-M', '-MM', '-MF', t.name)
      end

      @o_path = @project.path_to_o(path)
      dependencies << @project.directory(o_path.dirname)

      file o_path.to_s => [*dependencies, *depend, *@parent.dependencies, mf_path.to_s,
                           *Utility.read_mf(mf_path)] do |t|
        @project.cmd_compile(*flags_compile, '-c', t.source, '-o', t.name)
      end
    end
  end
end
