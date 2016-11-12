#!/usr/bin/ruby

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/RakeBuilder'

class TestGeneratedFile < Test::Unit::TestCase
  include RakeBuilder::Transform

  context('TestGeneratedFile') {
    setup {
      @seq = sequence('rule sequence')
    }

    should('create file rule') {
      GeneratedFile.new(name: 'path/main.cpp') { |t|
        t.code = proc { |fileName|
          File.open(fileName, 'w') { |file|
            file.write 'xxx'
          }
        }

        t.expects(:file).with(t.name => ['path'])
      }
    }

    should('create file rule with description') {
      GeneratedFile.new(name: 'path/main.cpp') { |t|
        t.description = 'desc'
        t.code = proc { |fileName| }

        t.expects(:description).with(t.description).in_sequence(@seq)
        t.expects(:file).in_sequence(@seq)
      }
    }

    should('be converted by Names') {
      gen = GeneratedFile.new(name: 'path/main.cpp') { |t|
        t.code = proc { |fileName| }

        t.expects(:file).at_least(0)
      }

      assert_equal(['path/main.cpp'], RakeBuilder::Names[gen])
    }
  }
end

