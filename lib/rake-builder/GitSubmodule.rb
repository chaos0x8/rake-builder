require_relative 'RakeBuilder'

class GitSubmodule
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name
  attr_reader :libs

  def initialize(name: nil, libs: [])
    extend RakeBuilder::Desc

    @name = name
    @libs = RakeBuilder::Libs.new(libs)

    yield(self) if block_given?

    required(:name, :libs)

    file("#{@name}/.git") {
      sh 'git submodule init'
      sh 'git submodule update'
    }

    C8.task(@name => ["#{@name}/.git"]) {
      @libs.each { |lib|
        sh "cd #{Shellwords.escape(@name)} && rake #{Shellwords.escape(lib)}"
      }
    }

    @libs.each { |lib|
      file("#{@name}/#{lib}" => [@name])
    }
  end

  def _names_
    @libs.collect { |lib|
      "#{@name}/#{lib}"
    }
  end

  def _build_
    @libs.collect { |lib|
      "#{@name}/#{lib}"
    }
  end
end

