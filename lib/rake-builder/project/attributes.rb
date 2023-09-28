require_relative '../utility/container_path'
require_relative '../error/unsuported_type'

module RakeBuilder
  module Attributes
    def self.included(mod)
      mod.define_singleton_method :attr_container do |name, type|
        if type.is_a? Proc
          define_method name do
            unless instance_variable_defined?(:"@#{name}_")
              instance_variable_set(:"@#{name}_",
                                    instance_exec(&type))
            end
            instance_variable_get(:"@#{name}_")
          end
        else
          define_method name do
            m = type.instance_method(:initialize)
            named_params = m.parameters.select { |k, _v| k == :keyreq }.collect { |_k, v| v }

            params = named_params.collect do |k, _v|
              case k
              when :parent_
                [:parent_, self]
              when :project_
                if is_a? ::RakeBuilder::Project
                  [:project_, nil]
                else
                  unless instance_variable_defined?(:@project)
                    raise ScriptError,
                          "`#{self.class}' doesn't provide `@project'!"
                  end

                  [:project_, @project]
                end
              else
                raise ScriptError, "Type `#{type}' has unsupported named param!"
              end
            end

            unless instance_variable_defined?(:"@#{name}_")
              instance_variable_set(:"@#{name}_",
                                    type.new(**params.to_h))
            end
            instance_variable_get(:"@#{name}_")
          end
        end
      end

      mod.define_singleton_method :attr_conv do |name, conv|
        define_method :"#{name}=" do |val|
          instance_variable_set(:"@#{name}", conv.call(val))
        end

        attr_reader name
      end

      mod.define_singleton_method :attr_type_safe do |name, types|
        define_method :"#{name}=" do |val|
          raise Error::UnsuportedType, val unless types.include?(val.class)

          instance_variable_set(:"@#{name}", val)
        end

        attr_reader :name
      end

      mod.define_singleton_method :attr_tracked do
        attr_container 'tracked', Utility::ContainerPath
      end

      mod.define_singleton_method :attr_dependencies do
        attr_container 'dependencies', Utility::ContainerString
      end

      mod.define_singleton_method :attr_path do
        attr_conv :path, ->(v) { Utility.to_pathname(v) }
      end

      mod.define_singleton_method :attr_description do
        attr_conv :description, ->(v) { v.to_s }

        define_method :rake_desc do
          desc description if description
        end
      end

      mod.define_singleton_method :attr_erb do
        attr_type_safe :erb, [Proc, String]
      end

      mod.define_singleton_method :allow_pkg_config do
        define_method :pkg_config do |*pkgs|
          pkg = Utility::PkgConfig.new(*pkgs.flatten)

          flags << pkg.flags if respond_to?(:flags)
          flags_link << pkg.flags_link if respond_to?(:flags_link)
        end
      end
    end
  end
end
