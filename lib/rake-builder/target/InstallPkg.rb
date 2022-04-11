require_relative '../c8/Task'
require_relative '../c8/Install'

class InstallPkg
  include RakeBuilder::Utility
  include Rake::DSL
  include C8::Install

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
    C8.phony(@name) do
      apt_install(*pkgs)
    end
  end

  def _names_
    @name
  end
end

def require_pkg(pkg)
  klass = Class.new do
    include C8::Install
  end

  klass.new.apt_install pkg

  nil
end
