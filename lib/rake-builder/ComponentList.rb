require_relative 'Utility'

module RakeBuilder
  class ComponentList
    include RakeBuilder::Utility
    include Rake::DSL

    def self.read name
      if File.exist? name
        files = IO.readlines(name, chomp: true)

        if files.any? { |fn| not File.exist?(fn) }
          return []
        else
          return files
        end
      else
        return []
      end
    end

    attr_accessor :name, :requirements, :sources

    def initialize(name: nil, sources: [])
      @name = name
      @sources = sources.collect(&:name)

      yield(self) if block_given?

      required(:name, :sources)

      if ComponentList.read(name) != @sources
        sh 'rm', name if File.exist?(name)
      end

      dir = Names[Directory.new(name: @name)]
      file(@name => Names[dir, @sources]) { |t|
        IO.write(t.name, @sources.join("\n"))
      }
    end

    def _names_
      [@name]
    end
  end
end
