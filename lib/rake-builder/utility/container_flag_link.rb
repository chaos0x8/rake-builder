require_relative 'container_flag'
require_relative 'to_pathname'

module RakeBuilder
  module Utility
    class ContainerFlagLink < ContainerFlag
      def initialize(parent_flags_ = nil)
        super(parent_flags_)
      end

      def to_a
        if @parent_flags
          (@parent_flags.instance_variable_get(:@value) + @value).collect(&:to_s).uniq
        else
          @value.collect(&:to_s).uniq
        end
      end

      def link_static(lib)
        @value << lib
      end

      def link_dynamic(lib)
        lib = Utility.to_pathname(lib)
        short_name = lib.basename.sub_ext('').sub(/^lib/, '')
        @value += %W[-Wl,-rpath=#{lib.dirname} -L#{lib.dirname} -l#{short_name}]
      end
    end
  end
end
