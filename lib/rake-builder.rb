#!/usr/bin/env ruby

autoload :Open3, 'open3'
autoload :Shellwords, 'shellwords'
autoload :FileUtils, 'fileutils'

require 'rake'

require_relative 'rake-builder/Build.rb'
require_relative 'rake-builder/Colorize.rb'
require_relative 'rake-builder/ComponentList.rb'
require_relative 'rake-builder/Directory.rb'
require_relative 'rake-builder/Errors.rb'
require_relative 'rake-builder/Names.rb'
require_relative 'rake-builder/PkgConfig.rb'
require_relative 'rake-builder/Pkgs.rb'
require_relative 'rake-builder/RakeBuilder.rb'
require_relative 'rake-builder/RakeInstaller.rb'
require_relative 'rake-builder/SharedSources.rb'
require_relative 'rake-builder/Transform.rb'
require_relative 'rake-builder/Utility.rb'
require_relative 'rake-builder/array-wrapper.rb'
require_relative 'rake-builder/c8.rb'
require_relative 'rake-builder/generate.rb'
require_relative 'rake-builder/target.rb'

require_pkg 'pkg-config'