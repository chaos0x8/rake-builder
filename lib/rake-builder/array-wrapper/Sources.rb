require_relative 'ArrayWrapper'

module RakeBuilder
  class Sources
    include Enumerable

    def initialize(sources, flags:, includes:, requirements:)
      @value = Array.new
      @flags = flags
      @includes = includes
      @requirements = requirements

      self << sources
    end

    def << sources
      [ sources ].flatten.uniq.each { |src|
        if src.kind_of? Sources
          self << src.value
        elsif src.kind_of? SourceFile
          @value << src
        else
          @value << SourceFile.new(name: src, flags: @flags, includes: @includes, requirements: @requirements)
        end
      }

      self
    end

    def each &block
      @value.each(&block)
    end

    def _names_
      @value
    end

    def - other
      @value.reject { |val|
        name = (val.kind_of?(SourceFile) ? val.name : val)
        [ other ].flatten.any? { |item|
          itemName = (item.kind_of?(SourceFile) ? item.name : item)
          name == itemName
        }
      }
    end

  protected
    attr_reader :value
  end
end
