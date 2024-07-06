require_relative 'mixin/attributes'
require_relative 'mixin/trackable'
require_relative 'mixin/cleanable'
require_relative '../utility/erb'

module RakeBuilder
  class Generate
    include Rake::DSL
    extend Attributes
    extend Trackable
    extend Cleanable

    attribute :path, Attr::Path
    attribute :description, Attr::String
    attribute :text, Attr::String
    attribute :dependencies, Attr::StringContainer, assignable: false
    attribute :depend, Attr::StringContainer

    attribute_collect :collect_dependencies, Attr::StringContainer,
                      self: %i[tl_path path]

    define_clean :tl_path, :path

    def initialize project, path:, data: {}, **opts
      @project = project
      __init_attributes__(path: path, **opts)
      @data = data
      __init_track__
      __init_target__
    end

    def __init_target__
      dependencies << tl_path unless tl_path.nil?

      desc(description) if description?
      file path.to_s => [*depend, *dependencies] do |t|
        file_content = Utility.erb({ path: path, track: track }.merge(@data), text)
        IO.write(t.name, file_content)
      end
    end
  end
end
