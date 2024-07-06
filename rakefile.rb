#!/usr/bin/ruby

require_relative 'lib/rake-builder/project/project'
require_relative 'lib/rake-builder/project/generate'
require_relative 'lib/rake-builder/project/tasks'

project = RakeBuilder::Project.new
project.generate path: 'lib/rake-builder.rb',
                 track: Pathname.new('lib/rake-builder').glob('*/*.rb'),
                 text: <<~TEXT
                   <%- track.each do |p| -%>
                   require_relative '<%= p.relative_path_from(path.dirname) %>'
                   <%- end -%>
                 TEXT
project.define_tasks

desc 'Executes unit tests'
task :test do
  sh 'rspec', *Dir['tests/**/*_spec.rb']
end
