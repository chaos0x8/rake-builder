gem 'rake-builder'

require 'rake-builder'

p = project do |t|
  t.flags << %w[--std=c++17]

  t.library 'libhello.a' do |t|
    t.sources << %w[src/hello.cpp]
  end

  t.executable 'main' do |t|
    t.sources << %w[src/main.cpp]
  end
end

desc 'Build and execute'
multitask default: [*p.requirements] do
  sh './main'
end

desc 'Clean'
task :clean do
  p.clean
end
