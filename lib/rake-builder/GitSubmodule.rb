class GitSubmodule
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :libs

  def initialize(name: nil, libs: [])
    @name = name
    @libs = libs

    yield(self) if block_given?

    required(:name, :libs)

    file("#{@name}/.git") {
      sh 'git submodule init'
      sh 'git submodule update'
    }

    @libs.each { |library|
      file("#{@name}/#{library}" => ["#{@name}/.git"]) {
        sh "cd #{@name} && rake #{Shellwords.escape(library)}"
      }

      Rake::Task["#{@name}/#{library}"].invoke
    }
  end

  def _names_
    @libs.collect { |lib|
      "#{@name}/#{lib}"
    }
  end
end

