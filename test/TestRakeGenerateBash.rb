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

    should('add simple complete') {
      content = Generate.bash {
        complete 'fun', ['--help']
      }

      expected = [
        "#!/bin/bash",
        "",
        "_fun() {",
        "  local cur=\"${COMP_WORDS[COMP_CWORD]}\"",
        "",
        "  if [ $COMP_CWORD -eq 1 ]; then",
        "    COMPREPLY=($(compgen -W \"--help\" -- \"${cur}\"))",
        "    return 0",
        "  fi",
        "",
        "  COMPREPLY=()",
        "}",
        "",
        "complete -F _fun fun",
        ""
      ].join "\n"

      assert_equal(expected, content)
    }

    should('add array complete') {
      content = Generate.bash {
        complete 'fun', ['--help', '--dry-run']
      }

      expected = [
        "#!/bin/bash",
        "",
        "_fun() {",
        "  local cur=\"${COMP_WORDS[COMP_CWORD]}\"",
        "",
        "  COMPREPLY=($(compgen -W \"--help --dry-run\" -- \"${cur}\"))",
        "}",
        "",
        "complete -F _fun fun",
        ""
      ].join "\n"

      assert_equal(expected, content)
    }

    should('add hash complete') {
      content = Generate.bash {
        complete 'fun', { '--name' => ['kevin', 'kora'], '--lastname' => ['starlight'], '--gender' => nil }
      }

      expected = [
        "#!/bin/bash",
        "",
        "_fun() {",
        "  local cur=\"${COMP_WORDS[COMP_CWORD]}\"",
        "  local prev=\"${COMP_WORDS[COMP_CWORD-1]}\"",
        "",
        "  case \"${prev}\" in",
        "    --name)",
        "      COMPREPLY=($(compgen -W \"kevin kora\" -- \"${cur}\"))",
        "      return 0",
        "      ;;",
        "    --lastname)",
        "      COMPREPLY=($(compgen -W \"starlight\" -- \"${cur}\"))",
        "      return 0",
        "      ;;",
        "    *)",
        "      ;;",
        "  esac",
        "",
        "  COMPREPLY=($(compgen -W \"--name --lastname --gender\" -- \"${cur}\"))",
        "}",
        "",
        "complete -F _fun fun",
        ""
      ].join "\n"

      assert_equal(expected, content)
    }

    should('add if else') {
      content = Generate.bash {
        if_else '[ $1 -eq 42 ]', proc {
          echo "ok"
        }, else_: proc {
          echo "fail"
        }
      }

      expected = [
        "#!/bin/bash",
        "",
        "if [ $1 -eq 42 ]; then",
        "  echo ok",
        "else",
        "  echo fail",
        "fi",
        ""
      ].join "\n"

      assert_equal(expected, content)
    }
  }
end

