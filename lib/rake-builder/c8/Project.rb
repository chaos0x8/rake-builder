require_relative 'Target'

module C8
  class Project
    class File
      attr_reader :path

      def initialize(path)
        @path = path.is_a?(Pathname) ? path : Pathname.new(path)
      end

      def make_rule(project)
        dirname = project.to_out(path, '').dirname

        project.directory dirname
        project.file project.to_out(path, '.mf').to_s => [path.to_s, dirname.to_s] do |t|
          C8.sh project.gpp, *project.flags,
                '-c', t.source, '-M', '-MM', '-MF', t.name,
                verbose: project.verbose, silent: project.silent
        end

        project.file project.to_out(path,
                                    '.o').to_s => [path.to_s, dirname.to_s, project.to_out(path, '.mf').to_s] do |t|
          C8.sh project.gpp, *project.flags,
                '-c', t.source, '-o', t.name,
                verbose: project.verbose, silent: project.silent,
                nonVerboseMessage: "#{project.gpp} #{t.source}"
        end

        project.to_out(path, '.o').to_s
      end
    end

    class Sources
      include Enumerable

      def initialize
        @files = []
      end

      def <<(value)
        case value
        when Array
          value.each do |v|
            self << v
          end
        when File
          self << value
        else
          @files << File.new(value)
        end
      end

      def each(&block)
        @files.each(&block)
      end

      def size
        @files.size
      end
    end

    class Flags
      def initialize
        @flags = []
      end

      def <<(value)
        case value
        when Array
          value.each do |v|
            self << v
          end
        else
          @flags << value
        end
      end

      def to_a
        @flags
      end
    end

    class Item
      attr_reader :path, :sources, :flags

      def initialize(path)
        @path = path.is_a?(Pathname) ? path : Pathname.new(path)
        @desc = nil
        @sources = Sources.new
        @flags = Flags.new
      end

      def dirname
        path.dirname
      end

      def desc(value)
        @desc = value
      end
    end

    class Executable < Item
      attr_reader :libs

      def initialize(*args,  **opts, &block)
        super(*args, **opts, &block)

        @libs = []

        instance_exec(self, &block)
      end

      def make_rule(project:)
        object_files = sources.collect do |src|
          src.make_rule project
        end

        project.directory dirname

        project.method(:desc).super_method.call @desc
        project.file path.to_s => [*object_files, dirname.to_s, *libs, *project.preconditions] do |t|
          C8.sh project.gpp, *project.flags, *object_files, *flags,
                '-o', t.name,
                verbose: project.verbose, silent: project.silent,
                nonVerboseMessage: "#{project.gpp} #{t.name}"
        end

        path.to_s
      end

      def link(lib)
        libs << lib.path.to_s
        flags << "-L#{lib.path.dirname}"
        flags << "-l#{lib.path.basename.sub_ext('').sub(/^lib/, '')}"
      end
    end

    class Library < Item
      def initialize(*args,  **opts, &block)
        super(*args, **opts, &block)

        instance_exec(self, &block)
      end

      def make_rule(project:)
        object_files = sources.collect do |src|
          src.make_rule project
        end

        project.directory dirname

        project.method(:desc).super_method.call @desc
        project.file path.to_s => [*object_files, dirname.to_s, *project.preconditions] do |t|
          C8.sh project.ar, 'vsr', t.name, *object_files,
                verbose: project.verbose, silent: project.silent,
                nonVerboseMessage: "#{project.ar} #{t.name}"
        end

        path.to_s
      end
    end

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

      instance_exec(self, &block)

      dependencies << @library.make_rule(project: self) if @library

      if @executable
        @executable.link @library if @library
        dependencies << @executable.make_rule(project: self)
      end

      if @test
        @test.link @library if @library
        dependencies << @test.make_rule(project: self)
      end

      method(:desc).super_method.call @desc
      C8.multitask(@name => dependencies)
    end

    def build_dir=(value)
      @build_dir = value.is_a?(Pathname) ? value : Pathname.new(value)
    end

    def desc(value)
      @desc = value
    end

    def executable(name, &block)
      @executable = Executable.new name, &block
    end

    def test(name, &block)
      @test = Executable.new name, &block
    end

    def library(name, &block)
      @library = Library.new name, &block
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

    def file(*args, **opts, &block)
      dependencies << args.first if args.size > 0
      dependencies << opts.keys.first if opts.size > 0

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
