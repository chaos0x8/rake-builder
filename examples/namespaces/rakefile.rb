gem 'rake-builder'

require 'rake-builder'

desc 'Builds and executes application'
multitask default: 'demo:default'

desc 'Removes build files'
multitask clean: 'demo:clean'
