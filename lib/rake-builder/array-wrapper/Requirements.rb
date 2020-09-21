require_relative 'ArrayWrapper'

module RakeBuilder
  class Requirements < ArrayWrapper
    def _names_
      @value
    end
  end
end
