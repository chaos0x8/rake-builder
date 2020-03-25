require_relative 'ArrayWrapper'

module RakeBuilder
  class Requirements < ArrayWrapper
    include VIterable

    def _names_
      @value
    end
  end
end
