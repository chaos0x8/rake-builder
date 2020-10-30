require_relative '../RakeBuilder'

autoload :JSON, 'json'

module C8
  class Config
    extend Rake::DSL

    @@task_defined = false

    def self.has_key? key
      data = data_ || {}
      data.has_key?(key.to_s)
    end

    def self.[] key
      data = data_ || {}
      data[key.to_s]
    end

    def self.[]= key, value
      data = data_ || {}
      data[key.to_s] = value
      FileUtils.mkdir_p File.dirname(filename_), verbose: true unless File.directory?(File.dirname(filename_))
      IO.write(filename_, JSON.pretty_generate(data))
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
        file(filename_) {
          IO.write(filename_, JSON.pretty_generate(data_ || {}))
        }
        @@task_defined = true
      end

      filename_
    end

  private
    def self.data_
      if File.exist?(filename_)
        JSON.parse(IO.read(filename_))
      end
    end

    def self.filename_
      File.join(RakeBuilder.outDir, 'config.json')
    end
  end
end
