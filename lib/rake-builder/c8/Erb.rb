autoload :ERB, 'erb'

module C8
  def self.erb filename, trim_mode = '-', **variables
    cls = Class.new {
      def initialize **opts
        opts.each { |key, value|
          instance_variable_set(:"@#{key}", value)
        }
      end

      def generate filename, trim_mode
        b = binding

        erb = ERB.new(IO.read(filename), nil, trim_mode)
        erb.result b
      end
    }

    o = cls.new(**variables)
    o.generate(filename, trim_mode)
  end
end
