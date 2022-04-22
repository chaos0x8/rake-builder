require_relative 'target'
require_relative 'utility'
require_relative 'project_flags'
require_relative 'project_executable'
require_relative 'project_library'

module C8
  class Project
    include Rake::DSL

    attr_reader :flags, :name, :dependencies, :preconditions
    attr_accessor :build_dir, :gpp, :ar, :verbose, :silent

    def initialize(name, &block)
      self.build_dir = '.obj'
      self.gpp = 'g++'
      self.ar = 'ar'
      self.verbose = true
      self.silent = false

      @name = name
      @desc = nil
      @flags = Flags.new
      @directory = []
      @dependencies = []
      @preconditions = []
      @to_generate = []
      @executable = []
      @library = []

      instance_exec(self, &block)

      if @to_generate.size > 0
        @preconditions << "#{@name}_to_generate"
        C8.phony "#{@name}_to_generate" do
          @to_generate.each do |path|
            Rake::Task[path].invoke
          end
        end
      end

      @library.each do |lib|
        lib.make_rule(project: self)
      end

      @executable.each do |exe|
        @library.each do |lib|
          exe.link lib
        end

        exe.make_rule(project: self)
      end

      method(:desc).super_method.call @desc
      C8.multitask(@name => dependencies)
    end

    def build_dir=(value)
      @build_dir = C8::Utility.to_pathname(value)
    end

    def desc(value)
      @desc = value
    end

    def executable(name, &block)
      Executable.new(name, &block).tap do |exe|
        @executable << exe
      end
    end

    def test(name, &block)
      Executable.new(name, &block).tap do |exe|
        @executable << exe
      end
    end

    def library(name, &block)
      Library.new(name, &block).tap do |lib|
        @library << lib
      end
    end

    def phony(name, &block)
      @preconditions << name
      C8.target name, type: :phony, &block
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

      directory path.dirname

      file path.to_s => [*sources, path.dirname.to_s, *preconditions] do |t|
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
      build_dir.join(path).sub_ext(path.extname + ext)
    end
  end

  def self.project(name, &block)
    Project.new name, &block
  end
end
