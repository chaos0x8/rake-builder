require_relative '../utility/containers'
require_relative '../builder'
require 'forwardable'

module RakeBuilder
  module DSL
    module Base
      def depend(arg)
        dependencies << arg unless dependencies.include?(arg)
      end

      def dependencies
        unless instance_variable_defined?(:@dependencies)
          instance_variable_set(:@dependencies,
                                Utility::StringContainer.new)
        end
        instance_variable_get(:@dependencies)
      end

      def track(arg)
        tracked << arg unless tracked.include?(arg)
      end

      def tracked
        instance_variable_set(:@tracked, Utility::Paths.new) unless instance_variable_defined?(:@tracked)
        instance_variable_get(:@tracked)
      end

      def builder
        RakeBuilder.instance_variable_get(:@builder)
      end

      def self.included(mod)
        mod.define_singleton_method :def_attr do |name, init|
          define_method name do
            unless instance_variable_defined?(:"@#{name}")
              case init
              when Class
                instance_variable_set(:"@#{name}", init.new)
              when Proc
                instance_variable_set(:"@#{name}", instance_exec(&init))
              else
                raise ScriptError, "Expected a `Class` or `Proc`, but got: `#{init.class}`"
              end
            end

            instance_variable_get(:"@#{name}")
          end
        end

        mod.define_singleton_method :def_clean do |*items|
          define_method :clean do
            to_clean = Utility::StringContainer.new.tap do |c|
              items.each do |item|
                c << send(item)
              end
            end

            to_clean -= instance_variable_get(:@exclude_from_clean) if instance_variable_defined?(:@exclude_from_clean)

            Utility.clean to_clean
          end

          define_method :exclude_from_clean do |arg|
            unless instance_variable_defined?(:@exclude_from_clean)
              instance_variable_set(:@exclude_from_clean,
                                    Utility::StringContainer.new)
            end
            instance_variable_get(:@exclude_from_clean) << arg
          end
        end

        mod.define_singleton_method :def_pkg_config do
          define_method :pkg_config do |*pkgs|
            unless respond_to?(:flags) or respond_to?(:link_flags)
              raise ScriptError,
                    'Neither flags or link_flags are defined!'
            end

            Utility::StringContainer.new.tap do |c|
              c << pkgs
            end.each do |pkg|
              flags << Utility.pkg_config('--cflags', pkg) if respond_to?(:flags)
              link_flags << Utility.pkg_config('--libs', pkg) if respond_to?(:link_flags)
            end
          end
        end
      end
    end
  end
end
