module C8
  class Project
    module DSL
      Attr = Struct.new(:value, :mode)

      def self.included(mod)
        mod.define_singleton_method :project_attr_writer do |name, default: nil|
          mod.instance_variable_set(:@project_attrs, {}) unless mod.instance_variable_defined?(:@project_attrs)
          mod.instance_variable_get(:@project_attrs)[name] = Attr.new(default, :w)

          define_method name do |value|
            instance_variable_set(:"@#{name}", value)
          end
        end

        mod.define_singleton_method :project_attr_reader do |name, default: nil|
          mod.instance_variable_set(:@project_attrs, {}) unless mod.instance_variable_defined?(:@project_attrs)
          mod.instance_variable_get(:@project_attrs)[name] = Attr.new(default, :r)
          mod.attr_reader name
        end

        mod.define_singleton_method :project_attr_accessor do |name, default: nil|
          mod.instance_variable_set(:@project_attrs, {}) unless mod.instance_variable_defined?(:@project_attrs)
          mod.instance_variable_get(:@project_attrs)[name] = Attr.new(default, :rw)
          mod.attr_accessor name
        end
      end

      def initialize_project_attrs(**opts)
        cls = self.class

        loop do
          cls.instance_variable_get(:@project_attrs)&.each do |name, default|
            if default.mode == :r && opts.has_key?(name)
              raise ArgumentError,
                    "Attempt to everride read only attribute: #{name}"
            end

            case default.value
            when Proc
              instance_variable_set(:"@#{name}", opts.fetch(name) { instance_exec(&default.value) })
            else
              instance_variable_set(:"@#{name}", opts.fetch(name, default.value.dup))
            end

            opts.delete(name)
          end

          cls = cls.superclass

          break unless cls
        end

        raise ArgumentError, "Unrecognized options: #{opts.keys.join(', ')}" unless opts.empty?
      end
    end
  end
end
