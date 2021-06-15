require_relative '../RakeBuilder'

autoload :JSON, 'json'

module C8
  class Config
    extend Rake::DSL

    @@task_defined = false
    @@filename = File.join(RakeBuilder.outDir, 'config.json')

    def self.filename= value
      @@filename = value
    end

    def self.filename
      @@filename
    end

    def self.has_key? key
      data = data_
      data.has_key?(key.to_s)
    end

    def self.[] key
      data = data_
      data[key.to_s]
    end

    def self.[]= key, value
      data = data_
      data[key.to_s] = value
      json = JSON.pretty_generate(data)
      if not File.exist?(@@filename) or IO.read(@@filename) != json
        if dir = File.dirname(@@filename) and not File.directory?(dir)
          FileUtils.mkdir_p dir, verbose: true
        end

        IO.write(@@filename, json)
      end
      value
    end

    def self.register name, default: nil
      unless self.has_key? name.to_sym
        self[name] = default
      end

      define_singleton_method(name) {
        self[name]
      }

      define_singleton_method(:"#{name}=") { |val|
        self[name] = val
      }
    end

    def self._names_
      unless @@task_defined
        file(@@filename) { |t|
          if File.exist?(t.name)
            FileUtils.touch t.name
          else
            IO.write(@@filename, JSON.pretty_generate({}))
          end
        }
        @@task_defined = true
      end

      @@filename
    end

  private
    def self.data_
      if File.exist?(@@filename)
        JSON.parse(IO.read(@@filename))
      else
        Hash.new
      end
    end
  end
end
