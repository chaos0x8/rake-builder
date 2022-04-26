require 'pathname'
require 'fileutils'

module C8
  module Utility
    def self.to_pathname(v)
      v.is_a?(Pathname) ? v : Pathname.new(v)
    end

    def self.read_mf(mf, &block)
      mf = to_pathname(mf)

      return to_enum(:read_mf, mf).to_a unless block_given?
      return unless mf.exist?

      dependencies = Shellwords.split(IO.read(mf).gsub("\\\n", '')).reject do |x|
        x.match(/#{Regexp.quote('.o:')}$/)
      end

      if dependencies.any? { |fn| !File.exist?(fn) }
        FileUtils.rm mf, verbose: true
        return
      end

      dependencies.each(&block)
    end

    def self.read_cl(cl, &block)
      cl = to_pathname(cl)

      return to_enum(:read_cl, cl).to_a unless block_given?
      return unless cl.exist?

      dependencies = IO.readlines(cl, chomp: true)

      if dependencies.any? { |fn| !File.exist?(fn) }
        FileUtils.rm cl, verbose: true
        return
      end

      dependencies.each(&block)
    end

    def self.pkg_config option, pkg
      o, s = Open3.capture2e('pkg-config', option, pkg)
      raise RakeBuilder::MissingPkg, pkg unless s.exitstatus == 0
      Shellwords.split(o)
    end
  end
end
