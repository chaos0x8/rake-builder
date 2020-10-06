require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../../lib/rake-builder'

class TestConfig < Test::Unit::TestCase
  context('C8::TestConfig') {
    teardown {
      Names[C8::Config].each { |fn|
        if File.exist?(fn)
          FileUtils.rm(fn)
        end
      }
    }

    should('should respond to names') {
      assert_equal(['.obj/config.json'], Names[C8::Config])
    }

    should('return nil when config is empty') {
      assert_equal(nil, C8::Config['debug'])
      assert(!File.exist?(Names[C8::Config].first))
      assert(!C8::Config.has_key?('debug'))
    }

    should('store data') {
      assert_equal(42, C8::Config['version'] = 42)
      assert(File.exist?(Names[C8::Config].first))
      assert(C8::Config.has_key?('version'))
    }

    should('read stored data') {
      C8::Config['version'] = 42

      assert_equal(42, C8::Config['version'])
      assert(C8::Config.has_key?('version'))
    }
  }
end



