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

    [
      {
        tag: :foo,
        regTags: [:foo, 'foo'],
        values: [nil, 42, 'Hello']
      },
      {
        tag: 'bar',
        regTags: [:bar, 'bar'],
        values: [80, 'xXx', nil]
      }
    ].each_with_index { |test, i1|
      tag, regTags, values = test.fetch_values(:tag, :regTags, :values)

      regTags.each_with_index { |regTag, i2|
        should("register field/#{i1}.#{i2}") {
          C8::Config.register(regTag)
          assert(C8::Config.has_key?(tag))
          assert_equal(nil, C8::Config.send(tag))
          assert_equal(nil, C8::Config[tag])
        }

        should("register field with default value/#{i1}.#{i2}") {
          C8::Config.register(regTag, default: 42)
          assert(C8::Config.has_key?(tag))
          assert_equal(42, C8::Config.send(tag))
          assert_equal(42, C8::Config[tag])
        }

        values.each_with_index { |value, i3|
          should("not override existing value with default/#{i1}.#{i2}.#{i3}") {
            C8::Config[tag] = 79

            C8::Config.register(regTag, default: value)

            assert_equal(79, C8::Config.send(tag))
            assert_equal(79, C8::Config[tag])
          }
        }
      }

      values.each_with_index { |value, i2|
        should("change registered field via tag/#{i1}.#{i2}") {
          C8::Config.register(tag)

          C8::Config.send(:"#{tag}=", value)

          assert_equal(value, C8::Config.send(tag))
          assert_equal(value, C8::Config[tag])
        }

        should("change registered field via operator[]/#{i1}.#{i2}") {
          C8::Config.register(tag)

          C8::Config[tag] = value

          assert_equal(value, C8::Config.send(tag))
          assert_equal(value, C8::Config[tag])
        }
      }
    }
  }
end



