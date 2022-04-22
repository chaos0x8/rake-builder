gem 'rake-builder'

require 'rake-builder'

desc 'Builds and executes application'
C8.task default: 'demo:default'

desc 'Removes build files'
C8.task clean: 'demo:clean'
