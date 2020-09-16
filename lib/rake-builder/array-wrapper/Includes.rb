require_relative 'ArrayWrapper'

module RakeBuilder
  class Includes < ArrayWrapper
    def _build_
      @value.collect { |inc| "-I#{inc}" }
    end
  end
end
