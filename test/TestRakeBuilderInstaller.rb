#!/usr/bin/ruby

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/rake-builder/RakeBuilder'

class TestInstaller < Test::Unit::TestCase
  context('TestInstaller') {
    setup {
      @pidok = 42
      @stok = mock('st ok')
      @stok.stubs(:exitstatus => 0)

      @pidnok = 50
      @stnok = mock('st nok')
      @stnok.stubs(:exitstatus => 1)

      Process.expects(:spawn).never

      Process.stubs(:wait2).with(@pidok).returns([@pidok, @stok])
      Process.stubs(:wait2).with(@pidnok).returns([@pidnok, @stnok])
    }

    setup {
      $stdout.stubs(:puts)
    }

    context('Task') {
      [:name, :pkgs].each { |missing|
        should("raise when #{missing} is missing") {
          opts = { name: 'install', pkgs: 'ruby-dev' }
          assert_raise(RakeBuilder::MissingAttribute) {
            InstallPkg.new(**opts.merge({missing => nil}))
          }
        }
      }

      should('install pkg when it is not installed') {
        InstallPkg.new(name: :install_pkg_1, pkgs: 'ruby-dev')

        Process.expects(:spawn).with('dpkg', '-s', 'ruby-dev', [:out, :err] => '/dev/null').returns(@pidnok)
        Process.expects(:spawn).with('sudo', 'apt', 'install', '-y', 'ruby-dev').returns(@pidok)

        Rake::Task[:install_pkg_1].invoke
      }

      should('do nothing when already installed') {
        InstallPkg.new(name: :install_pkg_2, pkgs: 'ruby-dev')

        Process.expects(:spawn).with('dpkg', '-s', 'ruby-dev', [:out, :err] => '/dev/null').returns(@pidok)

        Rake::Task[:install_pkg_2].invoke
      }

      should('raise when installation fails') {
        InstallPkg.new(name: :install_pkg_3, pkgs: 'ruby-dev')

        Process.expects(:spawn).with('dpkg', '-s', 'ruby-dev', [:out, :err] => '/dev/null').returns(@pidnok)
        Process.expects(:spawn).with('sudo', 'apt', 'install', '-y', 'ruby-dev').returns(@pidnok)

        assert_raise(RakeBuilder::PkgsInstalationError) {
          Rake::Task[:install_pkg_3].invoke
        }
      }
    }

    context('InPlace') {
      should('install pkg when it is not installed') {
        Process.expects(:spawn).with('dpkg', '-s', 'ruby-dev', [:out, :err] => '/dev/null').returns(@pidnok)
        Process.expects(:spawn).with('sudo', 'apt', 'install', '-y', 'ruby-dev').returns(@pidok)

        require_pkg 'ruby-dev'
      }

      should('do nothing when already installed') {
        Process.expects(:spawn).with('dpkg', '-s', 'ruby-dev', [:out, :err] => '/dev/null').returns(@pidok)

        require_pkg 'ruby-dev'
      }

      should('raise when installation fails') {
        Process.expects(:spawn).with('dpkg', '-s', 'ruby-dev', [:out, :err] => '/dev/null').returns(@pidnok)
        Process.expects(:spawn).with('sudo', 'apt', 'install', '-y', 'ruby-dev').returns(@pidnok)

        assert_raise(RakeBuilder::PkgsInstalationError) {
          require_pkg 'ruby-dev'
        }
      }
    }
  }
end
