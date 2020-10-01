require 'forwardable'

module RakeBuilder
  module ExOnNames
    def _names_
      raise TypeError.new("This type ('#{self.class}') should not be used by Names")
    end
  end

  module ExOnBuild
    def _build_
      raise TypeError.new("This type ('#{self.class}') should not be used by Build")
    end
  end

  class ArrayWrapper
    include ExOnNames
    include ExOnBuild
    include Enumerable

    extend Forwardable

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
          @value = @value.flatten.uniq.compact
        end
      end

      self
    end

    def_delegators :@value, :each, :empty?, :size

  protected
    attr_reader :value
  end
end
