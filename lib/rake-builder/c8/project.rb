require_relative 'target'
require_relative 'utility'
require_relative 'project_containers'
require_relative 'project_executable'
require_relative 'project_library'
require_relative 'project_templates'
require_relative 'project_dsl'

module C8
  class Project
    include Rake::DSL
    include Project::DSL

    attr_reader :name, :dependencies, :preconditions
    attr_accessor :build_dir, :gpp, :ar, :verbose, :silent

    project_attr_reader :flags, default: -> { Flags.new }
    project_attr_reader :link_flags, default: -> { Flags.new }
    project_attr_reader :preconditions, default: -> { Container.new }
    project_attr_writer :description, default: -> { 'Build task' }

    def initialize(name, &block)
      self.build_dir = '.obj'
      self.gpp = 'g++'
      self.ar = 'ar'
      self.verbose = true
      self.silent = false

      initialize_project_attrs

      @name = name
      @directory = []
      @dependencies = []
      @to_generate = []
      @executable = []
      @library = []
      @external = []
      @deps = { main: [], test: [] }

      namespace @name do
        instance_exec(self, &block)

        if @to_generate.size > 0
          @preconditions << "#{@name}_to_generate"
          C8.multiphony "#{@name}_to_generate" => @to_generate
        end

        @external.each do |ext|
          ext.make_rule(project: self)
        end

        @library.each do |lib|
          case lib
          when String, Pathname
            nil
          when C8::Project::Library
            lib.make_rule(project: self)
          else
            raise ScriptError, "Unsupported library class '#{lib.class}'"
          end
        end

        @executable.each do |exe|
          @library.each do |lib|
            exe.link lib
          end

          @external.each do |ext|
            exe.link ext
          end

          exe.make_rule(project: self)
        end

        unless @deps[:main].empty?
          deps = @deps[:main].reduce([]) do |sum, tgt|
            sum + tgt.output_paths
          end

          desc 'Build project'
          C8.multitask main: deps
        end

        unless @deps[:test].empty?
          deps = @deps.reduce([]) do |sum, (_key, tgts)|
            sum + tgts.reduce([]) do |sum, tgt|
              sum + tgt.output_paths
            end
          end

          desc 'Build and run tests'
          C8.multitask test: deps.collect(&:to_s) do
            @deps[:test].each do |exe|
              sh ::File.join('.', exe.path)
            end
          end
        end

        unless dependencies.empty?
          desc 'Build all'
          C8.multitask all: dependencies
        end

        project = self

        C8.target :clean do
          description 'Clean all'

          project.dependencies.each do |path|
            rm path
          end
        end
      end

      desc @description if @description
      C8.multitask(@name => dependencies)
    end

    def build_dir=(value)
      @build_dir = C8::Utility.to_pathname(value)
    end

    def pkg_config(pkg)
      @flags << C8::Utility.pkg_config('--cflags', pkg)
      @link_flags << C8::Utility.pkg_config('--libs', pkg)
    end

    def executable(name, &block)
      Executable.new(name, &block).tap do |exe|
        @executable << exe
        @deps[:main] << exe
      end
    end

    def test(name, &block)
      Executable.new(name, &block).tap do |exe|
        @executable << exe
        @deps[:test] << exe
      end
    end

    def library(name, &block)
      Library.new(name, &block).tap do |lib|
        @library << lib
        @deps[:main] << lib
      end
    end

    def external(*args, &block)
      External.new(*args, &block).tap do |ext|
        @external << ext
      end
    end

    def phony(name, &block)
      @preconditions << name
      C8.target name, type: :phony, &block
    end

    def header(name)
      Header.new(name).tap do |header|
        @to_generate << header.make_rule(self)
      end
    end

    def precompiled_header(name)
      PrecompiledHeader.new(name).tap do |header|
        @to_generate << header.make_rule(self)
      end
    end

    def directory(path)
      path = path.is_a?(Pathname) ? path : Pathname.new(path)

      unless @directory.include?(path.expand_path)
        @directory << path.expand_path
        method(:directory).super_method.call path.to_s
      end
    end

    def file_generated(**opts, &block)
      path = nil
      sources = []

      if opts.size > 0
        path = C8::Utility.to_pathname(opts.keys.first)
        sources = case opts.values.first
                  when Array
                    opts.values.first
                  else
                    [opts.values.first]
                  end
      end

      cl_path = to_out(path, '.cl')
      cl_dirname = cl_path.dirname

      directory cl_dirname

      file cl_path.to_s => [*sources, cl_dirname.to_s] do |t|
        IO.write(t.name, sources.join("\n"))
      end

      directory path.dirname

      file path.to_s => [cl_path.to_s, *C8::Utility.read_cl(cl_path), path.dirname.to_s, *preconditions] do |t|
        IO.write(t.name, block.call)
      end

      @to_generate << path.to_s
    end

    def file(*args, **opts, &block)
      path = nil
      path = args.first if args.size > 0
      path = opts.keys.first if opts.size > 0

      return if dependencies.include?(path)

      dependencies << path

      method(:file).super_method.call(*args, **opts, &block)
    end

    def to_out(path, ext)
      path = C8::Utility.to_pathname(path)

      build_dir.join(path).sub_ext(path.extname + ext)
    end

    def link(lib)
      case lib
      when String, Pathname
        path = C8::Utility.to_pathname(lib)

        @library << path
        link_flags << "-L#{path.dirname}"
        link_flags << "-l#{path.basename.sub_ext('').sub(/^lib/, '')}"
      else
        @library << path
      end
    end

    def desc(arg)
      method(:desc).super_method.call(arg)
    end
  end

  def self.project(name, &block)
    Project.new name, &block
  end
end
