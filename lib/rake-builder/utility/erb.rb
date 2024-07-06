require 'erb'

module RakeBuilder
  module Utility
    class ErbContext
      attr_reader :__text__

      def initialize(opts, text)
        opts.each do |key, val|
          instance_variable_set(:"@#{key}", val)

          define_singleton_method key do
            instance_variable_get(:"@#{key}")
          end
        end

        @__text__ = text
      end

      def __binding__
        binding
      end
    end

    def self.erb(data, template)
      ctx = ErbContext.new(data, template)
      erb = ERB.new(ctx.__text__, trim_mode: '-')
      erb.result(ctx.__binding__)
    end
  end
end
