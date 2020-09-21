require_relative 'Deprecated'

def mkSources sources, flags: [], includes: [], pkgs: [], requirements: []
  Deprecated.deprecated mkSources: :SharedSources

  flags = RakeBuilder::Flags.new(flags)
  libs = RakeBuilder::Libs.new([])
  pkgs = RakeBuilder::Pkgs.new(pkgs, flags: flags, libs: libs)
  includes = RakeBuilder::Includes.new(includes)

  RakeBuilder::Sources.new(
    sources,
    flags: flags,
    includes: includes,
    requirements: requirements)
end

