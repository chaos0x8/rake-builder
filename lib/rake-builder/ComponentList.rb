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

    def initialize(name: nil, sources: [], rebuild: [:change, :missing])
      @name = name
      @sources = Names[sources]

      yield(self) if block_given?

      required(:name)

      if rebuild.include?(:missing) and ComponentList.read(name) != @sources
        sh 'rm', name if File.exist?(name)
      end

      file(@name => requirements_(rebuild)) { |t|
        IO.write(t.name, @sources.join("\n"))
      }
    end

    def _names_
      [@name]
    end

  private
    def requirements_ rebuild
      dir = Names[Directory.new(name: @name)]

      if rebuild.include? :change
        Names[dir, @sources]
      else
        Names[dir]
      end
    end
  end
end
