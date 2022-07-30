namespace :demo do
  demo = project do |p|
    p.flags << %w[--std=c++0x -ISource]

    p.configure 'install_pkgs' do |t|
      t.apt_install 'ruby-dev'
    end

    p.library 'lib/libmain.a' do |t|
      t.sources << %w[Source/Hello.cpp]
    end

    p.executable 'bin/main' do |t|
      t.sources << %w[Source/main.cpp]
    end
  end

  desc 'Builds and executes demo application'
  task default: [*demo.requirements] do
    sh 'bin/main'
  end

  desc 'Cleans demo application'
  task :clean do
    demo.clean
  end
end
