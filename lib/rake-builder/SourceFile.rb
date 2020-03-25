module RakeBuilder
  class SourceFile
    include RakeBuilder::Utility
    include RakeBuilder::Transform
    include Rake::DSL

    attr_accessor :name, :flags, :includes, :description

    def initialize(name: nil, flags: [], includes: [], requirements: [], description: nil)
      @name = name
      @flags = flags
      @includes = includes
      @description = description
      @requirements = Names[requirements]

      yield(self) if block_given?

      required(:name)

      dir = Names[Directory.new(name: to_obj(@name))]
      file(to_mf(@name) => [ dir, @requirements, readMf(to_mf(@name)), @name ].flatten) {
        sh "#{RakeBuilder::gpp} #{_build_join_(@flags)} #{_build_join_(@includes)} -c #{@name} -M -MM -MF #{to_mf(@name)}".squeeze(' ')
      }

      desc @description if @description
      file(to_obj(@name) => [ dir, @requirements, to_mf(@name), @name ].flatten) {
        sh "#{RakeBuilder::gpp} #{_build_join_(@flags)} #{_build_join_(@includes)} -c #{@name} -o #{to_obj(@name)}".squeeze(' ')
      }
    end

    def _names_
      to_obj(@name)
    end
  end
end
