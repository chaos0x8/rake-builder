require 'erb'

module C8
  module Detail
    def self.empty_binding
      binding
    end
  end

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

  def self.erb(variables, &block)
    variables.each do |key, value|
      b.local_variable_set(key, value)
    end

    erb = ERB.new(block.call, trim_mode: '-')
    erb.result C8::Detail.empty_binding
  end

  def self.erb_eval(data)
    case data
    when Proc
      erb = ERB.new(data.call, trim_mode: '-')
      erb.result data.binding
    when String
      erb = ERB.new(data, trim_mode: '-')
      erb.result C8::Detail.empty_binding
    when ErbContext
      erb = ERB.new(data.__text__, trim_mode: '-')
      erb.result data.__binding__
    else
      raise ArgumentError, "Expected `Proc', `String' or `ErbContext' but got: #{data.class}"
    end
  end
end
