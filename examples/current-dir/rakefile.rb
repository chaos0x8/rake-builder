gem 'rake-builder'

autoload :FileUtils, 'fileutils'

require 'rake-builder'

app = Executable.new { |t|
  t.name = File.basename(File.dirname(__FILE__))
  t.sources << FileList['*.cpp']
  t.flags << ['--std=c++17']
}

multitask(default: Names[app])

task(:clean) {
  [RakeBuilder.outDir, app.name].each { |fn|
    if File.directory?(fn)
      FileUtils.rm_rf fn, verbose: true
    elsif File.exist?(fn)
      FileUtils.rm fn, verbose: true
    end
  }
}
