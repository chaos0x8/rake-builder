require_relative 'string_container'
require_relative '../utility/cpp_standard'

module RakeBuilder
  module Attr
    class FlagsCompile < StringContainer
      def initialize(*args, **opts)
        super(*args, **opts)

        @cpp_standard = Utility::CppStandard.new(nil)
        @include_directories = Attr::StringContainer.new
      end

      def <<(val)
        if val.is_a?(FlagsCompile)
          @value += val.instance_variable_get(:@value)
          @cpp_standard << val.cpp_standard
          @include_directories << val.include_directories
        elsif val.is_a?(Hash)
          @cpp_standard << val.fetch(:std, nil)
          @include_directories << val.fetch(:I, [])

          val.delete(:std)
          val.delete(:I)

          raise ArgumentError, "Hash contains unsupported keys: #{val.keys.join(', ')}" unless val.keys.empty?
        else
          super(val)
        end

        self
      end

      def_hierarhy_get :cpp_standard
      def_hierarhy_get :include_directories

      def to_a
        [].tap do |res|
          res.append("--std=c++#{cpp_standard.value}") if cpp_standard.value
          res.append(*include_directories.collect { |arg| "-I#{arg}" })
          res.append(*value)
        end
      end

      private

      def __append__(val)
        case val
        when PkgConfig
          self << val.flags_compile
        when ::String
          if m = val.match(/^#{Regexp.quote('--std=c++')}(.*)$/)
            @cpp_standard << m[1]
          elsif m = val.match(/^-I(.*)$/)
            @include_directories << m[1]
          else
            super(val)
          end
        else
          super(val)
        end
      end
    end
  end
end
