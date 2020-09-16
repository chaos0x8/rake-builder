require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/rake-builder'

class TestOptionParser < Test::Unit::TestCase
  context('RakeBuilder::TestOptionParser') {
    setup {
      @options = {}

      @sut = RakeBuilder::OptionParser.new { |op|
        {help: '--help', foo: '--foo V', bar: '--[no-]bar'}.each { |tag, option|
          op.on(option) { |v|
            @options[tag] = v
          }
        }
      }
    }

    should('do nothing when no separator') {
      nonOptions = @sut.parse!(['--help'])

      assert_equal(['--help'], nonOptions)
      assert_equal({}, @options)
    }

    should('parse options after separator') {
      nonOptions = @sut.parse!(['arg1', '--lol', '--', '--help', '--foo', 'hello', 'arg2'])

      assert_equal(['arg1', '--lol', 'arg2'], nonOptions)
      assert_equal({help: true, foo: 'hello'}, @options)
    }

    should('display help') {
      help = "Usage: -e [options]\n" +
      "        --help\n" +
      "        --foo V\n" +
      "        --[no-]bar\n"
      assert_equal(help, "#{@sut}")
      assert_equal(help, @sut.help)
    }

    [:on, :on_head, :on_tail, :to_s, :help, :banner, :banner=, :separator].each { |method|
      should("respond to #{method}") {
        assert(@sut.respond_to?(method))
      }
    }
  }
end


