module RakeBuilder
  module ExOnNames
    def _names_
      raise TypeError.new('This type should not be used by Names')
    end
  end

  module ExOnBuild
    def _build_
      raise TypeError.new('This type should not be used by Build')
    end
  end

  class ArrayWrapper
    include ExOnNames
    include ExOnBuild
    include Enumerable

    def initialize item
      @value = Array.new
      self << item
    end

    def << item
      unless item.nil?
        if item.kind_of? ArrayWrapper
          self << item.value
        else
          @value << item
          @value = @value.flatten.uniq
        end
      end

      self
    end

    def each &block
      @value.each(&block)
    end

  protected
    attr_reader :value
  end

  module VIterable
    def each(&block)
      @value.each(&block)
    end
  end
end
