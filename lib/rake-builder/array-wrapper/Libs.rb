require_relative 'ArrayWrapper'

module RakeBuilder
  class Libs < ArrayWrapper
    def _names_
      @value.select { |x| x.respond_to?(:_names_) }
    end

    def _build_
      Build[@value]
    end
  end
end
