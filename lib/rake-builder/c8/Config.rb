require_relative '../RakeBuilder'

autoload :JSON, 'json'

module C8
  class Config
    extend Rake::DSL

    @@task_defined = false

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
      if not File.exist?(filename_) or IO.read(filename_) != json
        if dir = File.dirname(filename_) and not File.directory?(dir)
          FileUtils.mkdir_p dir, verbose: true
        end

        IO.write(filename_, json)
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
        file(filename_) { |t|
          if File.exist?(t.name)
            FileUtils.touch t.name
          else
            IO.write(filename_, JSON.pretty_generate({}))
          end
        }
        @@task_defined = true
      end

      filename_
    end

  private
    def self.data_
      if File.exist?(filename_)
        JSON.parse(IO.read(filename_))
      else
        Hash.new
      end
    end

    def self.filename_
      File.join(RakeBuilder.outDir, 'config.json')
    end
  end
end
