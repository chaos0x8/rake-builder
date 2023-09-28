require_relative '../error/unsuported_type'

require 'pathname'

module RakeBuilder
  module Utility
    def self.to_pathname(val)
      case val
      when Pathname
        val
      when String
        Pathname.new(val)
      else
        raise Error::UnsuportedType, val
      end
    end
  end
end
