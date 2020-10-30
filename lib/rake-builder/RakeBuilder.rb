module RakeBuilder
  def self.module_accessor **opts
    opts.each { |tag, initialValue|
      class_variable_set(:"@@#{tag}", initialValue)

      define_singleton_method(:"#{tag}") {
        class_variable_get(:"@@#{tag}")
      }

      define_singleton_method(:"#{tag}=") { |value|
        class_variable_set(:"@@#{tag}", value)
      }
    }
  end

  module_accessor gpp: 'g++', ar: 'ar'
  module_accessor outDir: '.obj'
  module_accessor verbose: true
  module_accessor silent: false

  module Desc
    def self.extended cls
      cls.instance_eval {
        @description = nil
      }
    end

    attr_accessor :description
    alias_method :desc=, :description=
  end
end
