autoload :ERB, 'erb'

module C8
  module Detail
    def self.empty_binding
      binding
    end
  end

  def self.erb(variables, &block)
    b = C8::Detail.empty_binding

    variables.each do |key, value|
      b.local_variable_set(key, value)
    end

    erb = ERB.new(block.call, trim_mode: '-')
    erb.result b
  end
end
