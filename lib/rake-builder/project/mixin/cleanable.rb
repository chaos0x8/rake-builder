require_relative '../../utility/clean'

module RakeBuilder
  module Cleanable
    def define_clean *attrs
      define_method :clean do
        attrs.each do |attr|
          objects = if attr.to_s =~ /^@/
                      instance_variable_get(attr)
                    else
                      send(attr)
                    end

          [objects].flatten.compact.each do |o|
            if o.respond_to?(:clean)
              o.clean
            else
              Utility.clean(o)
            end
          end
        end
      end
    end
  end
end
