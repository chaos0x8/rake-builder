require_relative '../RakeBuilder'

autoload :JSON, 'json'

module C8
  class Config
    extend Rake::DSL

    @@task_defined = false

    def self.has_key? key
      data = data_ || {}
      data.has_key?(key)
    end

    def self.[] key
      data = data_ || {}
      data[key]
    end

    def self.[]= key, value
      data = data_ || {}
      data[key] = value
      IO.write(filename_, JSON.pretty_generate(data))
      value
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
