require 'shellwords'
require 'securerandom'
require 'open3'

require_relative 'error'
require_relative 'utility/common'

module RakeBuilder
  class RakeBuilderImpl
    include Rake::DSL

    attr_reader :out_dir
    attr_accessor :gpp, :ar

    def initialize
      @directories = []
      @reserved_target_names = []
      @mutex = Mutex.new
      self.out_dir = '.obj'
      self.gpp = 'g++'
      self.ar = 'ar'
    end

    def reserve_target_name
      loop do
        name = SecureRandom.hex
        unless @reserved_target_names.include?(name)
          @reserved_target_names << name
          return name
        end
      end
    end

    def directory(path)
      path = Utility.to_pathname(path)

      return nil if path == Pathname.new('.')

      unless @directories.include?(path)
        @directories << path
        method(:directory).super_method.call(path)
      end

      path
    end

    def sh(*args, **opts)
      @mutex.synchronize do
        puts Shellwords.join(args)
      end

      pid, st = Process.wait2(Process.spawn(*args, **opts))
      raise "C8.sh failed! [#{Shellwords.join(args)}]" if st.exitstatus != 0

      nil
    end

    def script(code)
      @mutex.synchronize do
        puts code
      end

      st = Open3.popen2e('sh') do |stdin, stdout, thread|
        stdin.write code
        stdin.close

        stdout.each_line do |line|
          @mutex.synchronize do
            puts line
          end
        end

        thread.value
      ensure
        stdout.close
      end

      raise RakeBuilder::Error, 'C8.script failed!' if st.exitstatus != 0
    end

    def out_dir=(path)
      @out_dir = Utility.to_pathname(path)
    end

    %w[cl mf o].each do |ext|
      define_method(:"path_to_#{ext}") do |path|
        path_to_out(path, ext)
      end
    end

    private

    def path_to_out(path, ext)
      path = Utility.to_pathname(path)

      out_dir.join(path.dirname, "#{path.basename}.#{ext}")
    end
  end

  @builder = RakeBuilder::RakeBuilderImpl.new

  %i[sh script out_dir gpp gpp= ar ar=].each do |sym|
    define_singleton_method sym do |*args, **opts, &block|
      @builder.send(sym, *args, **opts, &block)
    end
  end
end
