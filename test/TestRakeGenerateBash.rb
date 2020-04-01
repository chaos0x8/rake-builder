require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/rake-builder'

class TestRakeGenerateBash < Test::Unit::TestCase
  context('TestRakeGenerateBash') {
    should('generate bash file prefix') {
      content = Generate.bash {}
      assert_equal("#!/bin/bash\n", content)
    }

    should('add line') {
      content = Generate.bash {
        self << '# line'
      }

      assert_match(/^# line$/, content)
    }

    should('add function') {
      content = Generate.bash {
        function('fn') {
          self << '# line'
        }
      }

      assert_match(/^fn\(\) {$\n^  # line$\n^}$/, content)
    }

    should('add if condition') {
      content = Generate.bash {
        if_('[ -f /tmp/f.txt ]') {
          self << '# line'
        }
      }

      expected = [
        'if [ -f /tmp/f.txt ]; then',
        '  # line',
        'fi'
      ].join "\n"

      assert_match(expected, content)
    }

    should('add source') {
      content = Generate.bash {
        source_static 'fn'
      }

      expected = "source #{Shellwords.escape(File.expand_path('fn'))}"

      assert_match(expected, content)
    }

    should('add conditional source') {
      content = Generate.bash {
        source 'fn'
      }

      expected = [
        "if [ -f #{Shellwords.escape(File.expand_path('fn'))} ]; then",
        "  source #{Shellwords.escape(File.expand_path('fn'))}",
        "fi"
      ].join "\n"

      assert_match(expected, content)
    }

    should('add cd') {
      content = Generate.bash {
        cd 'fn'
      }

      expected = "cd #{Shellwords.escape(File.expand_path('fn'))}"

      assert_match(expected, content)
    }

    should('add conditional apt install') {
      content = Generate.bash {
        apt_install 'wget'
      }

      expected = [
        "if ! dpkg -s wget > /dev/null 2> /dev/null; then",
        "  sudo apt install -y wget",
        "fi"
      ].join "\n"

      assert_match(expected, content)
    }

    should('add path export') {
      content = Generate.bash {
        path '/tmp/bin'
      }

      expected = [
        "export PATH=/tmp/bin:$PATH"
      ].join "\n"

      assert_match(expected, content)
    }

    [{ name: :variable, prefix: '' },
     { name: :export, prefix: 'export' },
     { name: :local, prefix: 'local' }].each { |name:, prefix:|
      should("add #{name}") {
        content = Generate.bash {
          send(name, 'v1' => '10', 'v2' => 15)
        }

        expected = [
          "#{prefix} v1=10".lstrip,
          "#{prefix} v2=15".lstrip
        ].join "\n"

        assert_match(expected, content)
      }
    }

    should('add echo') {
      content = Generate.bash {
        echo 'Hello world!'
      }

      expected = [
        "echo #{Shellwords.escape('Hello world!')}"
      ].join "\n"

      assert_match(expected, content)
    }

    should('return check declated/0') {
      txt = nil

      content = Generate.bash {
        txt = declared?('lol')
      }

      assert_equal(Generate.bash{}, content)
      assert_equal('declare -p lol > /dev/null 2> /dev/null', txt)
    }

    should('add check declated') {
      content = Generate.bash {
        if_(declared?('lol')) {
          self << "# line"
        }
      }

      expected = [
        "if declare -p lol > /dev/null 2> /dev/null; then",
        "  # line",
        "fi"
      ].join "\n"

      assert_match(expected, content)
    }
  }
end

