autoload :ERB, 'erb'

module C8
  def self.erb filename, **variables
    cls = Class.new {
      def initialize filename, **opts
        instance_variable_set(:"@__file__", filename)

        opts.each { |key, value|
          instance_variable_set(:"@#{key}", value)
        }
      end

      def generate
        b = binding

        erb = ERB.new(IO.read(@__file__))
        erb.result b
      end
    }

    o = cls.new(filename, **variables)
    o.generate
  end
end
