require_relative '../RakeBuilder'
require_relative '../array-wrapper/ArrayWrapper'

class ExternalProject
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :git, :wget, :submodule, :build, :rakefile, :noRebuild
  attr_writer :outDir
  attr_reader :libs, :includes, :rakeTasks, :path

  def initialize(name: nil, git: nil, wget: nil, submodule: nil, rakefile: nil, libs: nil, includes: nil, description: nil, rakeTasks: nil, outDir: nil)
    warn "#{self.class} is deprecated, use C8.project.external instead"
    extend RakeBuilder::Desc

    @name = name
    @description = description
    @git = git
    @wget = wget
    @submodule = submodule
    @rakefile = rakefile
    @noRebuild = false
    @outDir = outDir
    @libs = RakeBuilder::ArrayWrapper.new(libs)
    @includes = RakeBuilder::ArrayWrapper.new(includes)
    @rakeTasks = RakeBuilder::ArrayWrapper.new(rakeTasks)

    yield(self) if block_given?

    required(:name)
    required_alt(:rakefile, :rakeTasks)
    required_alt(:git, :wget, :submodule)
    required_val(:submodule) do |val|
      val != @name
    end

    @path = cloneTask(@git) if @git
    @path = downloadTask(@wget) if @wget
    @path = submoduleInit(@submodule) if @submodule

    if @rakefile
      C8.task(@name => @path) do
        C8.sh "cd #{Shellwords.escape(@path)} && rake -f #{Shellwords.escape(File.expand_path(@rakefile))} --rakelib /dev/null",
              verbose: true
      end
    end

    if @rakeTasks.size > 0
      C8.task(@name => @path) do
        C8.sh "cd #{Shellwords.escape(@path)} && rake #{@rakeTasks.to_a.join(' ')}", verbose: true
      end
    end
  end

  def outDir
    @outDir || RakeBuilder.outDir
  end

  def findLibs(*libs, enum: nil)
    libs.collect do |fn|
      r = retryOnce(proc {
        Dir[File.join(@path, '**', fn)].first
      }, recover: proc {
        invoke
      }, error: "failed to find #{fn}")

      enum << r if enum

      lib = File.basename(r)
      lib.slice!('lib')
      lib.chomp!(File.extname(r))

      case File.extname(fn)
      when '.so'
        ["-Wl,-rpath=#{File.dirname(r)}", "-L#{File.dirname(r)}", "-l#{lib}"]
      when '.a'
        ["-L#{File.dirname(r)}", "-l#{lib}"]
      else
        raise "Unsupported extension: #{File.extname(fn)}"
      end
    end.uniq
  end

  def findIncludes(*includes)
    includes.collect do |fn|
      retryOnce(proc {
        Dir[File.join(@path, '**', fn)].collect { |r| r.chomp(fn) }.first
      }, recover: proc {
        invoke
      }, error: "failed to find #{fn}")
    end.uniq
  end

  def >>(other)
    e = []

    @findLibs ||= findLibs(*@libs, enum: e)
    @findIncludes ||= findIncludes(*@includes)

    other.libs << @findLibs
    other.includes << @findIncludes
    other.requirements << e
    other.requirements << @name unless @noRebuild

    self
  end

  def _names_
    @name
  end

  private

  def cloneTask(url)
    path = File.join(outDir, File.basename(url).chomp('.git'))

    file(path => Names[Directory.new(outDir)]) do
      C8.sh 'git', 'clone', url, path
    end

    path
  end

  def downloadTask(url)
    [{ ext: '.tar.gz', tar_options: '-xzf' }].each do |hash|
      hash => { ext:, tar_options: }

      next unless url.match(/#{Regexp.quote(ext)}$/)

      archive = File.join(outDir, File.basename(url))
      path = File.join(outDir, File.basename(url).chomp(ext))
      file(path => Names[Directory.new(outDir)]) do
        C8.sh 'wget', url, '-O', archive
        C8.sh 'tar', '-C', File.dirname(archive), tar_options, archive
      ensure
        FileUtils.rm archive if File.exist? archive
      end

      return path
    end

    nil
  end

  def submoduleInit(submodule)
    file(submodule) do
      C8.sh 'git', 'submodule', 'init', verbose: true
      C8.sh 'git', 'submodule', 'update', verbose: true
    end

    submodule
  end

  def retryOnce(block, error:, recover: nil)
    if r = block.call
      r
    else
      recover.call
      if r = block.call
        r
      else
        raise error
      end
    end
  end

  def invoke
    Rake::Task[@name].invoke
  end
end
