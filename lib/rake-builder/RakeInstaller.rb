#!/usr/bin/env ruby

require_relative 'ArrayWrapper'
require_relative 'Utility'
require_relative 'Names'

module RakeBuilder
  class InstallPkgList < ArrayWrapper
    include VIterable
  end

  @@install_mutext = Mutex.new

  def install_lock &block
    @@install_mutext.synchronize {
      block.call
    }
  end

  def isPkgInstalled? pkg
    install_lock {
      pid, st = Process.wait2(Process.spawn('dpkg', '-s', pkg, [:out, :err] => '/dev/null'))
      st.exitstatus == 0
    }
  end

  def installPkgs *pkgs, verbose: false
    install_lock {
      if pkgs.size > 0
        $stdout.puts "Required pkg #{pkgs.collect { |x| "'#{x}'" }.join(', ')} are missing. Installing missing pkgs..."
        pid, st = Process.wait2(Process.spawn('sudo', 'apt', 'install', '-y', *pkgs))
        raise PkgsInstalationError.new(pkgs) unless st.exitstatus == 0
      end
    }

    nil
  end

  module_function :install_lock, :isPkgInstalled?, :installPkgs
end

def require_pkg pkg
  unless RakeBuilder::isPkgInstalled? pkg
    RakeBuilder::installPkgs pkg, verbose: true
  end

  nil
end
