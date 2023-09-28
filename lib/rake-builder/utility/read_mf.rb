require 'shellwords'

module RakeBuilder
  module Utility
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
  end
end
