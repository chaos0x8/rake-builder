#!/usr/bin/ruby

require_relative 'lib/rake-builder/dsl/generated_file'

include RakeBuilder::DSL

f = generated_file 'lib/rake-builder.rb' do |t|
  t.track Dir['lib/rake-builder/**/*.rb']

  t.erb = proc do
    <<~INLINE
      <%- t.tracked.each do |path| -%>
      require_relative '<%= path.relative_path_from(t.path.dirname) %>'
      <%- end -%>

      include RakeBuilder::DSL
    INLINE
  end
end

desc 'Default task'
task default: [f.path.to_s]

desc 'Executes unit tests'
task :test do
  sh 'rspec', *Dir['tests/**/*_spec.rb']
end
