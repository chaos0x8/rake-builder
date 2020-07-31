namespace(:libs) {
  lib = Library.new { |t|
      t.name = 'lib/libmain.a'
      t.requirements << 'install:all'
      t.sources << Dir['Source/*.cpp'] - [ 'Source/main.cpp' ]
      t.includes << [ 'Source' ]
      t.flags << [ '--std=c++0x' ]
      t.pkgs << [ 'ruby' ]
      t.description = 'Build testable library'
  }

  C8.multitask(all: Names[lib])
}
