autoload :ERB, 'erb'

module C8
  def self.erb data, trim_mode = '-', **variables
    cls = Class.new {
      def initialize **opts
        opts.each { |key, value|
          instance_variable_set(:"@#{key}", value)
        }
      end

      def generate data, trim_mode
        b = binding

        erb = ERB.new(data, nil, trim_mode)
        erb.result b
      end
    }

    o = cls.new(**variables)
    o.generate(data, trim_mode)
  end
end
