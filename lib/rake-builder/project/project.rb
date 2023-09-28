require_relative '../utility/container_flag_compile'
require_relative '../utility/container_flag_link'
require_relative '../utility/to_pathname'
require_relative '../utility/clean'
require_relative '../error/script_failure'

require 'open3'

module RakeBuilder
  class Project
    include Rake::DSL
    include Attributes

    attr_container :flags, Utility::ContainerFlagCompile
    attr_container :flags_link, Utility::ContainerFlagLink

    allow_pkg_config

    attr_reader :out_dir, :gpp
    attr_accessor :gpp, :ar

    def initialize
      @libraries_static = []
      @executables = []
      @externals = []
      @rake_directories = []
      @generated_files = []
      @generated_files_targets = []
      @gpp = 'g++'
      self.out_dir = '.obj'
      self.ar = 'ar'
    end

    def out_dir=(path)
      @out_dir = Utility.to_pathname(path)
    end

    def rake_directory(path)
      path = Utility.to_pathname(path)

      return nil if path == Pathname.new('.')

      unless @rake_directories.include?(path)
        @rake_directories << path
        directory path
      end

      path
    end

    def sh(*args)
      method(:sh).super_method.call(*args)
    end

    def sh_script(script_)
      st = Open3.popen2e('sh') do |stdin, stdout, thread|
        stdin.write script_
        stdin.close

        stdout.each_line do |line|
          puts line
        end

        thread.value
      ensure
        stdout.close
      end

      raise Error::ScriptFailure if st.exitstatus != 0
    end

    %w[tl mf o].each do |ext|
      define_method :"path_to_#{ext}" do |path|
        path_to_out(path, ext)
      end
    end

    def dependencies
      @libraries_static.each_with_object(Utility::ContainerString.new) do |lib, sum|
        sum << lib.dependencies << lib.path
      end.to_a +
        @executables.each_with_object(Utility::ContainerString.new) do |exe, sum|
          sum << exe.dependencies << exe.path
        end.to_a
    end

    def clean
      @libraries_static.each(&:clean)
      @executables.each(&:clean)

      Utility.clean(*@rake_directories)
    end

    def clean_external
      @externals.each(&:clean)
    end

    private

    def path_to_out(path, ext)
      path = Utility.to_pathname(path)
      out_dir.join(path.dirname, "#{path.basename}.#{ext}")
    end
  end
end
