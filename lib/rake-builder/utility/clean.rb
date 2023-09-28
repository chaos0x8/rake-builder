require 'pathname'
require 'fileutils'

module RakeBuilder
  module Utility
    def self.clean(*files)
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

      clean(*defer) if defer.size != files.size

      nil
    end
  end
end
