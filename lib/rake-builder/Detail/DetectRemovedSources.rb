require_relative 'Phony'

module RakeBuilder
  module Detail
    class DetectRemovedSources < Rake::Task
      def initialize
        (class << self; self; end).instance_eval {
          Dir['.obj/**/*.o', '.obj/**/*.mf'].each { |fn|
            src = [fn.chomp(File.extname(fn)) + '.cpp',
                   fn.chomp(File.extname(fn)) + '.c']
          }

          define_method(:timestamp) {
            Time.at 0
          }
        }
      end

      def self.define_task &block
        Rake.application.define_task(self, :rake_builder_detail_detect_removed_sources, &block)
      end
    end
  end
end

