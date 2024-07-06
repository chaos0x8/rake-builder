require_relative 'string_container'

module RakeBuilder
  module Attr
    class FlagsLink < StringContainer
      attr_reader :link, :dependencies

      def initialize(*args, **opts)
        super(*args, **opts)

        @link = Attr::StringContainer.new
        @dependencies = Attr::StringContainer.new
        @link_directories = Attr::StringContainer.new
      end

      def <<(val)
        if val.is_a?(FlagsLink)
          @value += val.instance_variable_get(:@value)
          @link += val.link
          @dependencies += val.dependencies
          @link_directories += val.link_directories
        elsif val.is_a?(Hash)
          val.fetch(:link, []).each do |val|
            self << val
          end

          val.delete(:link)

          raise ArgumentError, "Hash contains unsupported keys: #{val.keys.join(', ')}" unless val.keys.empty?
        else
          super(val)
        end

        self
      end

      def_hierarhy_get :link
      def_hierarhy_get :dependencies
      def_hierarhy_get :link_directories

      def to_a
        [].tap do |res|
          res.append(*link_directories.collect { |arg| "-L#{arg}" })
          res.append(*link)
          res.append(*value)
        end
      end

      def each_lib(&block)
        Enumerator.new do |e|
          link.each do |val|
            e << if m = val.match(/^-l(.*)$/)
                   m[1]
                 else
                   val
                 end
          end

          nil
        end.each(&block)
      end

      private

      def __append__(val)
        case val
        when PkgConfig
          self << val.flags_link
        when ::String
          if m = val.match(/^-l(.*)$/)
            @link << val
          elsif m = val.match(/^-L(.*)$/)
            @link_directories << m[1]
          elsif m = val.match(/^-.*$/)
            super(val)
          else
            @link << val
            @dependencies << val
          end
        else
          super(val)
        end
      end
    end
  end
end
