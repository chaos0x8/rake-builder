autoload :ERB, 'erb'

module C8
  module Detail
    def self.empty_binding
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
    else
      raise ArgumentError, "Expected `Proc` or `String` but got: #{data.class}"
    end
  end
end
