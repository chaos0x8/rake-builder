#!/usr/bin/ruby

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/RakeBuilder'

class TestDirectory < Test::Unit::TestCase
  include RakeBuilder::Transform

  context('TestDirectory') {
    should('create rule') {
      Directory.new(name: 'path-1/fn.cpp') { |t|
        t.expects(:directory).with('path-1')
      }
    }

    should('not create same directory multiple times') {
      Directory.new(name: 'path-2/fn-1.cpp') { |t|
        t.expects(:directory).with('path-2')
      }

      Directory.new(name: 'path-2/fn-2.cpp') { |t|
        t.expects(:directory).at_most(0)
      }
    }

    should('be converted by Names') {
      dir = Directory.new(name: 'path-3/fn-3.cpp') { |t|
        t.expects(:directory).at_least(0)
      }

      assert_equal(['path-3'], RakeBuilder::Names[dir])
    }
  }
end

