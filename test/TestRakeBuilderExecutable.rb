#!/usr/bin/ruby

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/RakeBuilder'

class TestExecutable < Test::Unit::TestCase
  context('TestExecutable') {
    should('raise when name is missing') {
      assert_raise(RakeBuilder::MissingAttribute) {
        Executable.new(sources: [ 'main.cpp' ])
      }
    }

    should('raise when sources are missing') {
      assert_raise(RakeBuilder::MissingAttribute) {
        Executable.new(name: 'name')
      }
    }
  }
end


