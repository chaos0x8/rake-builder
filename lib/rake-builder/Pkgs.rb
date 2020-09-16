require_relative 'array-wrapper/ArrayWrapper'

module RakeBuilder
  class Pkgs
    include ExOnNames
    include ExOnBuild

    class Item
      include PkgConfig

      def initialize type, name
        @type = type
        @name = name
        @value = nil
      end

      def _build_
        @value ||= pkgConfig(@type, @name)
      end

      def == other
        _cmp == other._cmp
      end

    protected
      def _cmp
        [ @type, @name ]
      end
    end

    def initialize(pkgs, flags:, libs:)
      @flags = flags
      @libs = libs
      @value = Array.new

      self << pkgs
    end

    def << pkgs
      [ pkgs ].flatten.reject { |pkg| pkg.nil? }.each { |pkg|
        if pkg.kind_of? Pkgs
          self << pkg.value
        else
          @flags << Pkgs::Item.new('--cflags', pkg)
          @libs << Pkgs::Item.new('--libs', pkg)
          @value << pkg
          @value = @value.flatten.uniq
        end
      }

      self
    end

    def value
      @value
    end
  end
end
