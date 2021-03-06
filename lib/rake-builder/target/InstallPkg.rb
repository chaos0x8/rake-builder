require_relative '../RakeInstaller'
require_relative '../c8/Task'

class InstallPkg
  include RakeBuilder::Utility
  include Rake::DSL

  attr_accessor :name, :description
  attr_reader :pkgs

  def initialize(name: nil, pkgs: [], description: nil)
    extend RakeBuilder::Desc

    @name = name
    @pkgs = RakeBuilder::InstallPkgList.new(pkgs)
    @description = description

    yield(self) if block_given?

    required(:name)

    desc @description if @description
    C8.phony(@name) {
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

