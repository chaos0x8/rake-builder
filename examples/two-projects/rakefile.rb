gem 'rake-builder'

require 'rake-builder'

project_a = RakeBuilder::Project.new
project_a.flags << %w[--std=c++17 -Isrc -DPROJECT_NAME=A]
project_a.out_dir = project_a.out_dir.join('a')

project_a.executable 'bin/project_a' do |t|
  t.sources << Dir['src/**/*.cpp']
end

project_b = RakeBuilder::Project.new
project_b.flags << %w[--std=c++17 -Isrc -DPROJECT_NAME=B]
project_b.out_dir = project_b.out_dir.join('b')

project_b.executable 'bin/project_b' do |t|
  t.sources << Dir['src/**/*.cpp']
end

desc 'Compile'
multitask compile: project_a.dependencies + project_b.dependencies

desc 'Compile'
task default: :compile

desc 'Clean'
task :clean do
  project_a.clean
  project_b.clean
end
