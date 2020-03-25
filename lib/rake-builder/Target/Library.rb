require_relative 'Target'

class Library < RakeBuilder::Target
  def initialize(*args, **opts)
    super(*args, **opts)

    dir = Names[Directory.new(name: @name)]
    desc @description if @description
    file(@name => Names[dir, @requirements, @sources]) {
      sh "#{RakeBuilder::ar} vsr #{@name} #{_build_join_(@sources)}"
    }
  end

  def _build_
    Build[@name]
  end
end

