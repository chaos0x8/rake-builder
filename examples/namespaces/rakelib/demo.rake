namespace :demo do
  p = C8.project 'demo' do
    flags << %w[--std=c++0x -ISource]

    phony 'install_pkgs' do
      apt_install 'ruby-dev'
    end

    library 'lib/libmain.a' do
      sources << %w[Source/Hello.cpp]
    end

    executable 'bin/main' do
      sources << %w[Source/main.cpp]
    end
  end

  desc 'Builds and executes application'
  C8.task default: 'demo:demo' do
    sh 'bin/main'
  end

  desc 'Removes build files'
  C8.target :clean do
    p.dependencies.each do |path|
      rm path
    end
  end
end
