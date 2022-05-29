module C8
  class Project
    module DSL
      def self.included(mod)
        mod.define_singleton_method :project_attr_writer do |name, default: nil|
          mod.instance_variable_set(:@project_attrs, {}) unless mod.instance_variable_defined?(:@project_attrs)
          mod.instance_variable_get(:@project_attrs)[name] = default

          define_method name do |value|
            instance_variable_set(:"@#{name}", value)
          end
        end

        mod.define_singleton_method :project_attr_reader do |name, default: nil|
          mod.instance_variable_set(:@project_attrs, {}) unless mod.instance_variable_defined?(:@project_attrs)
          mod.instance_variable_get(:@project_attrs)[name] = default
          mod.attr_reader name
        end
      end

      def initialize_project_attrs
        cls = self.class

        loop do
          cls.instance_variable_get(:@project_attrs)&.each do |name, default|
            case default
            when Proc
              instance_variable_set(:"@#{name}", instance_exec(&default))
            else
              instance_variable_set(:"@#{name}", default.dup)
            end
          end

          cls = cls.superclass

          break unless cls
        end
      end
    end
  end
end
