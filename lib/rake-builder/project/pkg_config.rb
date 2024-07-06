require 'open3'

module RakeBuilder
  class PkgConfig
    attr_reader :names, :flags_compile, :flags_link

    def initialize(pkgs)
      @names = [pkgs].flatten
      @flags_compile = []
      @flags_link = []

      @names.each do |pkg|
        @flags_compile += __capture__(pkg, '--cflags')
        @flags_link += __capture__(pkg, '--libs')
      end
    end

    private

    def __capture__(pkg, *args)
      out, st = Open3.capture2e('pkg-config', pkg, *args)
      raise Error::PkgConfigFailure, out.chomp if st.exitstatus != 0

      Shellwords.split(out)
    end
  end
end
