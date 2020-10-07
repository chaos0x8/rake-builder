require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../../lib/rake-builder'

class TestConfig < Test::Unit::TestCase
  context('C8::TestData') {
    should('initialize data section') {
      assert_equal("Hello world", C8.data(__FILE__).data)
    }

    should('initialize variables') {
      assert_equal('Variable1', C8.data(__FILE__).var1)
    }
  }
end

__END__
Hello world
@@var1=
Variable1
