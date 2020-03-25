#!/usr/bin/env ruby

autoload :Open3, 'open3'
autoload :Shellwords, 'shellwords'
autoload :FileUtils, 'fileutils'

require 'rake'

require_relative 'rake-builder/ArrayWrapper.rb'
require_relative 'rake-builder/Build.rb'
require_relative 'rake-builder/Directory.rb'
require_relative 'rake-builder/Errors.rb'
require_relative 'rake-builder/GeneratedFile.rb'
require_relative 'rake-builder/GitSubmodule.rb'
require_relative 'rake-builder/MkSource.rb'
require_relative 'rake-builder/Names.rb'
require_relative 'rake-builder/PkgConfig.rb'
require_relative 'rake-builder/Pkgs.rb'
require_relative 'rake-builder/RakeBuilder.rb'
require_relative 'rake-builder/RakeInstaller.rb'
require_relative 'rake-builder/SourceFile.rb'
require_relative 'rake-builder/Target.rb'
require_relative 'rake-builder/Transform.rb'
require_relative 'rake-builder/Utility.rb'
require_relative 'rake-builder/Generate.rb'

require_pkg 'pkg-config'