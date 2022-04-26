require_relative 'target'
require_relative 'utility'
require_relative 'project_containers'
require_relative 'project_executable'
require_relative 'project_library'
require_relative 'project_templates'

module C8
  class Project
    include Rake::DSL

    attr_reader :flags, :link_flags, :name, :dependencies, :preconditions
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
      @link_flags = Flags.new
      @directory = []
      @dependencies = []
      @preconditions = []
      @to_generate = []
      @executable = []
      @library = []
      @external = []

      instance_exec(self, &block)

      if @to_generate.size > 0
        @preconditions << "#{@name}_to_generate"
        C8.multiphony "#{@name}_to_generate" => @to_generate
      end

      @external.each do |ext|
        ext.make_rule(project: self)
      end

      @library.each do |lib|
        lib.make_rule(project: self)
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

      method(:desc).super_method.call @desc
      C8.multitask(@name => dependencies)
    end

    def build_dir=(value)
      @build_dir = C8::Utility.to_pathname(value)
    end

    def desc(value)
      @desc = value
    end

    def pkg_config pkg
      @flags << C8::Utility.pkg_config('--cflags', pkg)
      @link_flags << C8::Utility.pkg_config('--libs', pkg)
    end

    def executable(name, &block)
      Executable.new(name, &block).tap do |exe|
        @executable << exe
      end
    end

    def test(name, &block)
      warn 'test is deprecated use executable instead'
      Executable.new(name, &block).tap do |exe|
        @executable << exe
      end
    end

    def library(name, &block)
      Library.new(name, &block).tap do |lib|
        @library << lib
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
      build_dir.join(path).sub_ext(path.extname + ext)
    end
  end

  def self.project(name, &block)
    Project.new name, &block
  end
end
