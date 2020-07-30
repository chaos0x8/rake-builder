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
        value = instance_variable_get(:"@#{sym}")
        if value.nil? or (value.respond_to?(:empty?) and value.empty?)
          raise RakeBuilder::MissingAttribute.new(sym.to_s)
        end
      }
    end

    def required_alt *attributes
      count = attributes.count { |sym|
        value = instance_variable_get(:"@#{sym}")
        missing = value.nil? or (value.respond_to?(:empty?) and value.empty?)
        not missing
      }

      if count != 1
        raise RakeBuilder::AttributeAltError.new(*attributes)
      end
    end

    def _build_join_ obj
      Shellwords.join(Build[obj])
    end
  end
end
