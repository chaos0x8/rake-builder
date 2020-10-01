require 'rake'

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

    def is_missing? o
      o.nil? or (o.respond_to?(:empty?) and o.empty?)
    end

    def required *attributes
      attributes.each { |sym|
        value = instance_variable_get(:"@#{sym}")
        if is_missing?(value)
          raise RakeBuilder::MissingAttribute.new(sym.to_s)
        end
      }
    end

    def required_alt *attributes
      count = attributes.count { |sym|
        value = instance_variable_get(:"@#{sym}")
        !is_missing?(value)
      }

      if count != 1
        raise RakeBuilder::AttributeAltError.new(*attributes)
      end
    end
  end
end
