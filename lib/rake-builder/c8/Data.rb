module C8
  module Detail
    class DataParser
      class Variable
        attr_accessor :name
        attr_reader :data

        def initialize name
          @name = name
          @data = []
        end

        def hash
          [@name].hash
        end

        def eql? o
          [@name] == [o.name]
        end
      end

      def initialize filename
        lines = IO.readlines(filename, chomp: true)

        if lines.count { |l| l == '__END__' }
          dataIndex = lines.index('__END__')

          @data = lines[dataIndex+1..-1]
        end

        @variables = Set.new
        @var = nil
        @free = []
      end

      def parse
        @data.each { |line|
          if m = line.match(/^@@(\w+)=$/)
            setVar m[1]
          else
            self << line
          end
        }

        setVar nil

        cls = Class.new {
          def initialize variables, free
            variables.each { |v|
              instance_variable_set(:"@#{v.name}", v.data.join("\n"))

              self.class.define_method(:"#{v.name}") {
                instance_variable_get(:"@#{v.name}")
              }
            }

            if free.size > 0
              instance_variable_set(:@data, free.join("\n"))

              self.class.define_method(:data) {
                instance_variable_get(:@data)
              }
            end
          end
        }

        cls.new(@variables, @free)
      end

      def << line
        if @var
          @var.data << line
        else
          @free << line
        end
      end

    private
      def setVar name
        if @var
          @variables << @var
        end

        if name
          @var = Variable.new(name)
        else
          @var = nil
        end

        nil
      end
    end
  end

  def self.data filename
    dp = Detail::DataParser.new(filename)
    dp.parse
  end
end
