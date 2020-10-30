namespace(:install) {
  install = InstallPkg.new { |t|
    t.name = :installRuby
    t.pkgs << 'ruby-dev'
  }

  C8.phony(default: Names[install])
}
