#!/usr/bin/env ruby

require_relative 'RakeBuilder'

module RakeBuilder
  module Detail
    class Phony < Rake::Task
      def self.define_task *args, &block
        Rake.application.define_task(self, *args, &block)
      end

      def timestamp
        Time.at 0
      end
    end
  end

  class InstallPkgList < ArrayWrapper
    include VIterable
  end

  def isPkgInstalled? pkg
    pid, st = Process.wait2(Process.spawn('dpkg', '-s', pkg, [:out, :err] => '/dev/null'))
    st.exitstatus == 0
  end

  def installPkgs *pkgs, verbose: false
    if pkgs.size > 0
      $stdout.puts "Required pkg #{pkgs.collect { |x| "'#{x}'" }.join(', ')} are missing. Installing missing pkgs..."
      pid, st = Process.wait2(Process.spawn('sudo', 'apt', 'install', '-y', *pkgs))
      raise PkgsInstalationError.new(pkgs) unless st.exitstatus == 0
    end

    nil
  end

  module_function :isPkgInstalled?, :installPkgs
end

def require_pkg pkg
  unless RakeBuilder::isPkgInstalled? pkg
    RakeBuilder::installPkgs pkg, verbose: true
  end

  nil
end

class InstallPkg
  include RakeBuilder::Utility
  include Rake::DSL

  attr_accessor :name, :description
  attr_reader :pkgs

  def initialize(name: nil, pkgs: [], description: nil)
    @name = name
    @pkgs = RakeBuilder::InstallPkgList.new(pkgs)
    @description = description

    yield(self) if block_given?

    required(:name, :pkgs)

    RakeBuilder::Detail::Phony.define_task(@name) {
      pkgs = @pkgs.each.reject { |pkg|
        RakeBuilder::isPkgInstalled?(pkg)
      }

      RakeBuilder::installPkgs *pkgs, verbose: true
    }
  end

  def _names_
    @name
  end
end
