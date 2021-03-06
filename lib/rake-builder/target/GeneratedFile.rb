require_relative '../Utility'
require_relative '../Transform'
require_relative '../Directory'
require_relative '../RakeBuilder'
require_relative '../Names'
require_relative '../ComponentList'
require_relative '../array-wrapper/Requirements'
require_relative '../array-wrapper/Track'

autoload :Open3, 'open3'

class GeneratedFile
  include RakeBuilder::Utility
  include RakeBuilder::Transform
  include Rake::DSL

  attr_accessor :name, :action, :code, :requirements

  def initialize(name: nil, action: nil, code: nil, description: nil, requirements: [], format: false)
    extend RakeBuilder::Desc
    extend RakeBuilder::Track::Ext

    @name = name
    @action = action
    @code = code
    @requirements = RakeBuilder::Requirements.new(requirements)
    @description = description
    @format = format

    yield(self) if block_given?

    required(:name)
    required_alt(:code, :action)

    cl = cl_(rebuild: [:missing])

    dir = Names[Directory.new(@name)]
    desc @description if @description

    if @action
      file(@name => Names[dir, cl, @requirements]) {
        call_(@action)
      }
    end

    if @code
      file(@name => Names[dir, cl, @requirements]) {
        if txt = call_(@code)
          if txt.kind_of? Array
            txt = txt.join("\n")
          end

          if @format
            txt = format_(txt)
          end

          if File.exist?(@name) and IO.read(@name) == txt
            FileUtils.touch @name
          else
            IO.write(@name, txt)
          end
        end
      }
    end
  end

  alias_method :_names_, :name

private
  def call_ callback
    callback.call(@name, Names[@requirements].first)
  end

  def format_ txt
    out, st = Open3.capture2e('clang-format', '-assume-filename', @name, '-style=file', stdin_data: txt)
    if st.exitstatus == 0
      out.chomp
    else
      $stderr.puts "Warning: error during clang-format"
      $stderr.puts out.chomp

      txt
    end
  end
end

