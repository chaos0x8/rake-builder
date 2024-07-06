require_relative 'mixin/attributes'
require_relative 'mixin/trackable'
require_relative 'mixin/cleanable'

module RakeBuilder
  class CmakeConverter
    include Rake::DSL
    extend Attributes
    extend Trackable
    extend Cleanable

    attribute :path, Attr::Path, assignable: false, default: 'CMakeLists.txt'
    attribute :dependencies, Attr::StringContainer, assignable: false
    attribute :text, Attr::String

    attribute_collect :collect_dependencies, Attr::StringContainer,
                      self: :dependencies

    define_clean :path, :tl_path

    def initialize(project:, **opts)
      @project = project

      __init_attributes__(**opts)
      __init_target__
    end

    def name
      path.basename.to_s
    end

    def project_name
      @project.name
    end

    def __init_target__
      raise 'Can be only created once.' if self.class.instance_variable_get(:@instance)

      self.class.instance_variable_set(:@instance, object_id)

      project_name = (@project.name.empty? ? 'noname' : @project.name)
      libraries = extract_data(@project.instance_variable_get(:@libraries))
      executables = extract_data(@project.instance_variable_get(:@executables))
      cxx_standard = [*@project.instance_variable_get(:@libraries),
                      *@project.instance_variable_get(:@executables)].collect do |target|
        target.instance_variable_get(:@flags_compile).cpp_standard
      end.max

      template = <<~TEXT
        project(<%= project_name %>)

        <%- unless cxx_standard.value.nil? -%>
        set(CMAKE_CXX_STANDARD <%= cxx_standard.value %>)
        <%- end -%>

        <%- libraries.each do |lib| -%>
        add_library(<%= lib[:name] %>
          <%- lib[:sources].each do |src| -%>
          <%= src %>
          <%- end -%>
        )

        <%- unless lib[:include_directories].empty? -%>
        target_include_directories(<%= lib[:name] %> PRIVATE
          <%- lib[:include_directories].each do |dir| -%>
          <%= dir %>
          <%- end -%>
        )
        <%- end -%>

        <%- unless lib[:directory].empty? -%>
        set_target_properties(<%= lib[:name] %> PROPERTIES
          ARCHIVE_OUTPUT_DIRECTORY <%= lib[:directory] %>
          LIBRARY_OUTPUT_DIRECTORY <%= lib[:directory] %>
          RUNTIME_OUTPUT_DIRECTORY <%= lib[:directory] %>
        )
        <%- end -%>
        <%- end -%>

        <%- executables.each do |exe| -%>
        add_executable(<%= exe[:name] %>
          <%- exe[:sources].each do |src| -%>
          <%= src %>
          <%- end -%>
        )

        <%- unless exe[:include_directories].empty? -%>
        target_include_directories(<%= exe[:name] %> PRIVATE
          <%- exe[:include_directories].each do |dir| -%>
          <%= dir %>
          <%- end -%>
        )
        <%- end -%>

        <%- unless exe[:directory].empty? -%>
        set_target_properties(<%= exe[:name] %> PROPERTIES
          ARCHIVE_OUTPUT_DIRECTORY <%= exe[:directory] %>
          LIBRARY_OUTPUT_DIRECTORY <%= exe[:directory] %>
          RUNTIME_OUTPUT_DIRECTORY <%= exe[:directory] %>
        )
        <%- end -%>

        <%- unless exe[:link_directories].empty? -%>
        target_link_directories(<%= exe[:name] %> PRIVATE
          <%- exe[:link_directories].each do |dir| -%>
          <%= dir %>
          <%- end -%>
        )
        <%- end -%>

        <%- unless exe[:link_libraries].empty? -%>
        target_link_libraries(<%= exe[:name] %> PRIVATE
          <%- exe[:link_libraries].each do |lib| -%>
          <%= lib %>
          <%- end -%>
        )
        <%- end -%>
        <%- end -%>

        #{text}
      TEXT

      __init_track__

      file path.to_s => tl_path do |t|
        @project.generated.each do |path|
          Rake::Task[path].invoke
        end

        file_content = Utility.erb({
                                     project_name: project_name,
                                     libraries: libraries,
                                     executables: executables,
                                     cxx_standard: cxx_standard
                                   }, template)
        IO.write(t.name, file_content)
      end

      dependencies << path
      dependencies << tl_path unless tl_path.nil?

      task cmake: [*dependencies]
    end

    def target_name(path)
      path.basename.sub_ext('').to_s
    end

    private

    def extract_data(args)
      [].tap do |res|
        args.each do |arg|
          link_libraries = []
          link_directories = []

          if arg.respond_to?(:flags_link)
            arg.flags_link.each_lib do |lib|
              link_libraries << if builder_library = @project.find_library(lib)
                                  target_name(builder_library.path)
                                else
                                  lib
                                end
            end

            link_directories = arg.flags_link.link_directories
          end

          res << {
            name: target_name(arg.path),
            directory: Pathname.new('').join(*arg.path.each_filename.to_a[0...-1]),
            sources: arg.sources + arg.headers,
            include_directories: arg.instance_variable_get(:@flags_compile).include_directories,
            cpp_standard: arg.instance_variable_get(:@flags_compile).cpp_standard,
            link_libraries: link_libraries,
            link_directories: link_directories
          }

          track << arg.sources
        end
      end
    end

    instance_variable_set(:@instance, nil)
  end
end
