#!/usr/bin/ruby

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/RakeBuilder'

class TestSourceFile < Test::Unit::TestCase
  include RakeBuilder::Transform

  context('TestSourceFile') {
    setup {
      File.expects(:exists?).returns(false).at_least(0)

      @seq = sequence('rule sequence')
    }

    should('raise when name is not provided') {
      assert_raise(RakeBuilder::MissingAttribute) {
        SourceFile.new(
          flags: [ '--std=c++11' ],
          includes: [ 'Source' ]
        )
      }
    }

    should('create build rule') {
      SourceFile.new { |t|
        t.name = 'main.cpp'

        t.expects(:file).with { |x| x.keys.first == to_mf(t.name) }.in_sequence(@seq)
        t.expects(:file).with { |x| x.keys.first == to_obj(t.name) }.in_sequence(@seq)
      }
    }

    should('read dependencies before creating rules') {
      SourceFile.new { |t|
        t.name = 'main.cpp'

        File.expects(:exists?).with(to_mf(t.name)).returns(true).at_least(0)
        File.expects(:open).with(to_mf(t.name), 'r').returns(['file1']).at_least(0)

        t.expects(:file).with { |x| x.values.first.include?('file1') }.in_sequence(@seq)
        t.expects(:file).in_sequence(@seq)
      }
    }

    should('include dependency to .obj directory') {
      SourceFile.new { |t|
        t.name = 'main.cpp'

        t.expects(:file).with { |x| x.values.first.include?('.obj') }.in_sequence(@seq)
        t.expects(:file).in_sequence(@seq)
      }
    }

    should('describe rule') {
      SourceFile.new { |t|
        t.name = 'main.cpp'
        t.description = 'desc'

        t.expects(:file).in_sequence(@seq)
        t.expects(:desc).with(t.description).in_sequence(@seq)
        t.expects(:file).in_sequence(@seq)
      }
    }

    should('be converted by Names') {
      source = SourceFile.new { |t|
        t.name = 'main.cpp'

        t.expects(:file).at_least(0)
      }

      assert_equal([to_obj('main.cpp')], RakeBuilder::Names[source])
    }
  }
end
