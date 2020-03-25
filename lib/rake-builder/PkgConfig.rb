module RakeBuilder
  module PkgConfig
    def pkgConfig option, pkg
      o, s = Open3.capture2e('pkg-config', option, pkg)
      raise MissingPkg.new(pkg) unless s.exitstatus == 0
      Shellwords.split(o)
    end
  end
end
