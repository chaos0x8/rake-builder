#!/usr/bin/ruby

require_relative '../lib/RakeBuilder'

class TestableTarget < Target
  def initialize(**opts, &block)
    super
  end

  def peek symbol
    send(symbol)
  end
end

