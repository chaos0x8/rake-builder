#!/usr/bin/ruby

gem 'rake-builder', '~> 1.0', '>= 1.0.2'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

generated = []
generated << Generate.includeDirectory('Source/Common')

multitask(default: Names[generated])
