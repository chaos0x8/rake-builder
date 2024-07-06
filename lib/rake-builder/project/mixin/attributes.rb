require 'pathname'

module RakeBuilder
  module Attributes
    module Detail
      def self.access(o, symbol)
        case symbol.to_s
        when /^@/
          o.instance_variable_get(symbol) if o.instance_variable_defined?(symbol)
        when /^self$/
          o
        else
          o.send(symbol) if o.respond_to?(symbol)
        end
      end
    end

    AttrEntry = Struct.new(:name, :type, :assignable, :default, :opts) do
      def access_attr(o, name)
        return unless info = attr_info(name)

        access(o, info)
      end

      private

      def access(o, info)
        if info.is_a?(Array)
          i = info.shift
          o = Detail.access(o, i)
          return o if info.empty?

          access(o, info)
        else
          Detail.access(o, info)
        end
      end

      def attr_info(name)
        if opts.has_key?(name)
          opts.fetch(name)
        else
          name = :"AttrInfo#{name.capitalize}"
          type.const_get(name) if type.const_defined?(name)
        end
      end
    end

    def self.extended(mod)
      mod.instance_variable_set(:@attributes, [])
      mod.define_method :__init_attributes__ do |**opts|
        self.class.instance_variable_get(:@attributes).each do |attr_entry|
          entry_opts = {}

          if (parent = attr_entry.access_attr(self,
                                              :parent)) && parent.instance_variable_defined?(:"@#{attr_entry.name}")
            entry_opts[:parent] = parent.instance_variable_get(:"@#{attr_entry.name}")
          end

          1.times do |arg_idx|
            if (arg = attr_entry.access_attr(self, :"arg#{arg_idx}"))
              entry_opts[:"arg#{arg_idx}"] = instance_variable_get(arg)
            end
          end

          instance_variable_set(:"@#{attr_entry.name}", attr_entry.type.new(**entry_opts))

          if opts.has_key?(attr_entry.name)
            raise ArgumentError, "Attribute `#{attr_entry.name}' is not assignable." unless attr_entry.assignable

            instance_variable_get(:"@#{attr_entry.name}") << opts[attr_entry.name]
          elsif attr_entry.default
            instance_variable_get(:"@#{attr_entry.name}") << attr_entry.default
          end

          opts.delete(attr_entry.name)
        end

        opts.each do |attr_name, _attr_value|
          raise "Attributes `#{attr_name}' is not a valid attribute."
        end
      end
    end

    def attribute(name, type, assignable: true, default: nil, opts: {})
      instance_variable_get(:@attributes) << AttrEntry.new(name, type, assignable, default, opts)

      if type.instance_methods.include?(:value) && type.instance_methods.include?(:value?)
        define_method name do
          instance_variable_get(:"@#{name}").value
        end

        define_method :"#{name}?" do
          instance_variable_get(:"@#{name}").value?
        end
      else
        define_method name do
          instance_variable_get(:"@#{name}")
        end
      end

      nil
    end

    def attribute_collect(name, type, **spec)
      define_method name do
        type.new.tap do |result|
          spec.each do |symbol, accessors|
            objects = Detail.access(self, symbol)
            [objects].flatten.each do |o|
              [accessors].flatten.each do |accessor|
                value = Detail.access(o, accessor)
                result << value unless value.nil?
              end
            end
          end
        end
      end
    end
  end
end

Pathname.new(__dir__).join('../../attr').glob('*.rb').each do |attr_path|
  require attr_path
end
