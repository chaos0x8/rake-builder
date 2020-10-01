require_relative '../RakeBuilder'
require_relative '../array-wrapper/ArrayWrapper'

class ExternalProject
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :git, :wget, :build, :rakefile, :no_rebuild
  attr_reader :libs, :includes, :rake_tasks

  def initialize(name: nil, git: nil, wget: nil, rakefile: nil, libs: nil, includes: nil, description: nil, rake_tasks: nil)
    extend RakeBuilder::Desc

    @name = name
    @description = description
    @git = git
    @wget = wget
    @rakefile = rakefile
    @no_rebuild = false
    @libs = RakeBuilder::ArrayWrapper.new(libs)
    @includes = RakeBuilder::ArrayWrapper.new(includes)
    @rake_tasks = RakeBuilder::ArrayWrapper.new(rake_tasks)

    yield(self) if block_given?

    required(:name)
    required_alt(:rakefile, :rake_tasks)
    required_alt(:git, :wget)

    @output_dir = cloneTask(@git) if @git
    @output_dir = downloadTask(@wget) if @wget

    if @rakefile
      C8.task(@name => @output_dir) {
        C8.sh "cd #{Shellwords.escape(@output_dir)} && rake -f #{Shellwords.escape(File.expand_path(@rakefile))} --rakelib /dev/null", verbose: true
      }
    end

    if @rake_tasks.size > 0
      C8.task(@name => @output_dir) {
        C8.sh "cd #{Shellwords.escape(@output_dir)} && rake #{@rake_tasks.to_a.join(' ')}", verbose: true
      }
    end
  end

  def find_libs
    @libs.collect { |fn|
      r = retry_once(proc {
        Dir[File.join(@output_dir, '**', fn)].first
      }, recover: proc {
        invoke
      }, error: "failed to find #{fn}")

      case File.extname(fn)
      when '.so'
        lib = File.basename(r)
        lib.slice!('lib')
        lib.chomp!(File.extname(r))

        ["-Wl,-rpath=#{File.dirname(r)}", "-L#{File.dirname(r)}", "-l#{lib}"]
      when '.a'
        r
      else
        raise "Unsupported extension: #{File.extname(fn)}"
      end
    }.uniq
  end

  def find_includes
    @includes.collect { |fn|
      retry_once(proc {
        Dir[File.join(@output_dir, '**', fn)].collect { |r| r.chomp(fn) }.first
      }, recover: proc {
        invoke
      }, error: "failed to find #{fn}")
    }.uniq
  end

  def >> target
    target.libs << find_libs
    target.includes << find_includes
    target.requirements << @name unless @no_rebuild

    self
  end

  def _names_
    @name
  end

private
  def cloneTask url
    output_dir = File.join('.obj', File.basename(url).chomp('.git'))

    file(output_dir => Names[Directory.new('.obj')]) {
      C8.sh 'git', 'clone', url, output_dir
    }

    output_dir
  end


  def downloadTask url
    [{ ext: '.tar.gz', tar_options: '-xzf' }].each { |ext:, tar_options:|
      if url.match(/#{Regexp.quote(ext)}$/)
        archive = File.join('.obj', File.basename(url))
        output_dir = File.join('.obj', File.basename(url).chomp(ext))
        file(output_dir => Names[Directory.new('.obj')]) {
          begin
            sh 'wget', url, '-O', archive
            sh 'tar', '-C', File.dirname(archive), tar_options, archive
          ensure
            FileUtils.rm archive if File.exist? archive
          end
        }

        return output_dir
      end
    }

    return nil
  end

  def retry_once block, error:, recover: nil
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
