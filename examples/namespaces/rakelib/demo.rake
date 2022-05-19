namespace :demo do
  C8.project 'demo' do
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
end
