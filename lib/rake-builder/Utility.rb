module RakeBuilder
  module Utility
    include Rake::DSL

    def readMf(mf)
      if File.exist?(mf)
        File.open(mf, 'r') { |f|
          dependencies = Shellwords.split(f.read.gsub("\\\n", '')).reject { |x|
            x.match(/#{Regexp.quote('.o:')}$/)
          }

          if dependencies.any? { |fn| not File.exist?(fn) }
            sh "rm #{Shellwords.escape(mf)}"
            Array.new
          else
            dependencies
          end
        }
      else
        Array.new
      end
    end

    def required *attributes
      attributes.each { |sym|
        value = send(sym)
        raise RakeBuilder::MissingAttribute.new(sym.to_s) if value.nil? or (value.respond_to?(:empty?) and value.empty?)
      }
    end

    def _build_join_ obj
      Shellwords.join(Build[obj])
    end
  end
end
