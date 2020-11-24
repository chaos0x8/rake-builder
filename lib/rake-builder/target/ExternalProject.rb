require_relative '../RakeBuilder'
require_relative '../array-wrapper/ArrayWrapper'

class ExternalProject
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :git, :wget, :submodule, :build, :rakefile, :noRebuild
  attr_reader :libs, :includes, :rakeTasks

  def initialize(name: nil, git: nil, wget: nil, submodule: nil, rakefile: nil, libs: nil, includes: nil, description: nil, rakeTasks: nil)
    extend RakeBuilder::Desc

    @name = name
    @description = description
    @git = git
    @wget = wget
    @submodule = submodule
    @rakefile = rakefile
    @noRebuild = false
    @libs = RakeBuilder::ArrayWrapper.new(libs)
    @includes = RakeBuilder::ArrayWrapper.new(includes)
    @rakeTasks = RakeBuilder::ArrayWrapper.new(rakeTasks)

    yield(self) if block_given?

    required(:name)
    required_alt(:rakefile, :rakeTasks)
    required_alt(:git, :wget, :submodule)
    required_val(:submodule) { |val|
      val != @name
    }

    @outputDir = cloneTask(@git) if @git
    @outputDir = downloadTask(@wget) if @wget
    @outputDir = submoduleInit(@submodule) if @submodule

    if @rakefile
      C8.task(@name => @outputDir) {
        C8.sh "cd #{Shellwords.escape(@outputDir)} && rake -f #{Shellwords.escape(File.expand_path(@rakefile))} --rakelib /dev/null", verbose: true
      }
    end

    if @rakeTasks.size > 0
      C8.task(@name => @outputDir) {
        C8.sh "cd #{Shellwords.escape(@outputDir)} && rake #{@rakeTasks.to_a.join(' ')}", verbose: true
      }
    end
  end

  def findLibs *libs, enum: nil
    libs.collect { |fn|
      r = retryOnce(proc {
        Dir[File.join(@outputDir, '**', fn)].first
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
    }.uniq
  end

  def findIncludes *includes
    includes.collect { |fn|
      retryOnce(proc {
        Dir[File.join(@outputDir, '**', fn)].collect { |r| r.chomp(fn) }.first
      }, recover: proc {
        invoke
      }, error: "failed to find #{fn}")
    }.uniq
  end

  def >> target
    e = Array.new

    @findLibs ||= findLibs(*@libs, enum: e)
    @findIncludes ||= findIncludes(*@includes)

    target.libs << @findLibs
    target.includes << @findIncludes
    target.requirements << e
    target.requirements << @name unless @noRebuild

    self
  end

  def _names_
    @name
  end

private
  def cloneTask url
    outputDir = File.join(RakeBuilder.outDir, File.basename(url).chomp('.git'))

    file(outputDir => Names[Directory.new(RakeBuilder.outDir)]) {
      C8.sh 'git', 'clone', url, outputDir
    }

    outputDir
  end

  def downloadTask url
    [{ ext: '.tar.gz', tar_options: '-xzf' }].each { |ext:, tar_options:|
      if url.match(/#{Regexp.quote(ext)}$/)
        archive = File.join(RakeBuilder.outDir, File.basename(url))
        outputDir = File.join(RakeBuilder.outDir, File.basename(url).chomp(ext))
        file(outputDir => Names[Directory.new(RakeBuilder.outDir)]) {
          begin
            C8.sh 'wget', url, '-O', archive
            C8.sh 'tar', '-C', File.dirname(archive), tar_options, archive
          ensure
            FileUtils.rm archive if File.exist? archive
          end
        }

        return outputDir
      end
    }

    return nil
  end

  def submoduleInit submodule
    file(submodule) {
      C8.sh 'git', 'submodule', 'init', verbose: true
      C8.sh 'git', 'submodule', 'update', verbose: true
    }

    submodule
  end

  def retryOnce block, error:, recover: nil
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
