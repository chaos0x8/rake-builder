require_relative 'mixin/attributes'
require_relative 'mixin/cleanable'

module RakeBuilder
  class Project
    include Rake::DSL
    extend Attributes
    extend Cleanable

    attribute :name, Attr::String
    attribute :flags_compile, Attr::FlagsCompile
    attribute :flags_link, Attr::FlagsLink
    attribute :out_dir, Attr::Path, default: '.obj'
    attribute :gpp, Attr::String, default: 'g++'
    attribute :ar, Attr::String, default: 'ar'
    attribute :depend, Attr::StringContainer

    attribute_collect :collect_dependencies, Attr::StringContainer,
                      :self => %i[@depend],
                      :@generated => :collect_dependencies,
                      :@executables => :collect_dependencies,
                      :@libraries => :collect_dependencies

    define_clean :@generated, :@executables, :@libraries, :@directories, :@cmake

    def initialize(name: 'Default', **opts)
      @executables = []
      @libraries = []
      @directories = []
      @generated = []
      @cmake = nil

      opts = { out_dir: ".obj/#{name}" }.merge(opts) unless name.empty?

      __init_attributes__(name: name, **opts)
      __init_target__
    end

    def __init_target__; end

    def directory(path)
      path = Utility.to_pathname(path)

      return nil if path == Pathname.new('.')

      unless @directories.include?(path)
        @directories << path
        method(:directory).super_method.call(path)
      end

      path
    end

    def generate **opts
      @generated << Generate.new(self, **opts)
      @generated.last
    end

    def executable **opts
      @executables << Executable.new(self, **opts)
      @executables.last
    end

    def library_static **opts
      @libraries << LibraryStatic.new(self, **opts)
      @libraries.last
    end

    def generated
      @generated.collect do |x|
        x.path.to_s
      end
    end

    def find_library(path)
      path = path.to_s

      found = @libraries.find do |lib|
        lib.path.to_s == path
      end
      return found if found

      nil
    end

    def configure_cmake(**opts)
      @cmake = CmakeConverter.new(project: self, **opts)
    end

    def define_tasks
      Tasks.new(default: self, clean: [self, @cmake], cmake: @cmake)
    end

    def cmd_compile *args
      sh(gpp.to_s, *args.flatten.collect(&:to_s))
    end

    def cmd_link *args
      sh(ar.to_s, *args.flatten.collect(&:to_s))
    end

    %w[tl mf o].each do |ext|
      define_method :"path_to_#{ext}" do |path|
        path_to_out(path, ext)
      end
    end

    private

    def path_to_out(path, ext)
      path = Utility.to_pathname(path)
      out_dir.join(path.dirname, "#{path.basename}.#{ext}")
    end
  end
end
