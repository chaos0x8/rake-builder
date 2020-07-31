namespace(:install) {
  install = InstallPkg.new(name: :install, pkgs: ['ruby-dev'])

  C8.task(all: Names[install])
}

