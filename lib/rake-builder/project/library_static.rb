require_relative 'source'
require_relative 'mixin/attributes'
require_relative 'mixin/cleanable'

module RakeBuilder
  class LibraryStatic
    include Rake::DSL
    extend Attributes
    extend Cleanable

    attribute :path, Attr::Path
    attribute :description, Attr::String
    attribute :flags_compile, Attr::FlagsCompile, opts: { parent: :@project }
    attribute :dependencies, Attr::StringContainer, assignable: false
    attribute :sources, Attr::PathContainer
    attribute :headers, Attr::PathContainer
    attribute :depend, Attr::StringContainer, opts: { parent: :@project }

    attribute_collect :collect_dependencies, Attr::StringContainer,
                      :self => %i[path @depend @dependencies],
                      :@objects => :collect_dependencies

    define_clean :@objects, :path

    def initialize(project, path:, **opts)
      @project = project

      __init_attributes__(path: path, **opts)
      __init_objects__
      __init_target__
    end

    def __init_target__
      dependencies << @project.directory(path.dirname) if path.dirname != Pathname.new('.')
      dependencies << @objects.collect(&:o_path)

      desc(description) if description?
      file path.to_s => [*depend, *dependencies] do |t|
        @project.cmd_link('vsr', t.name, @objects.collect(&:o_path))
      end
    end

    def __init_objects__
      @objects = sources.collect do |path|
        Source.new(@project, self, path: path)
      end
    end
  end
end
