require 'fileutils'
require 'pathname'
require 'shellwords'

module RakeBuilder
  module Utility
    def self.to_pathname(path)
      case path
      when Pathname
        path
      else
        if path.respond_to? :path
          to_pathname(path.path)
        else
          Pathname.new(path)
        end
      end
    end

    def self.read_mf(path, &block)
      path = to_pathname(path)

      return to_enum(:read_mf, path) unless block_given?
      return unless path.exist?

      dependencies = Shellwords.split(IO.read(path).gsub("\\\n", '')).reject do |x|
        x.match(/#{Regexp.quote('.o:')}$/)
      end

      if dependencies.any? { |fn| !File.exist?(fn) }
        FileUtils.rm path, verbose: true
        return
      end

      dependencies.each(&block)
    end

    def self.clean(files)
      defer = []

      files.each do |path|
        path = to_pathname(path)

        if path.directory?
          if path.children.empty?
            FileUtils.rmdir path, verbose: true
          else
            defer << path
          end
        elsif path.exist?
          FileUtils.rm path, verbose: true
        end
      end

      clean(defer) if defer.size != files.size

      nil
    end

    def self.pkg_config(option, pkg)
      o, s = Open3.capture2e('pkg-config', option, pkg)
      raise RakeBuilder::MissingPkgError, pkg unless s.exitstatus == 0

      Shellwords.split(o)
    end
  end
end
