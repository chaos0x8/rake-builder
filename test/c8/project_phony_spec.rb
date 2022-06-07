gem 'bundler'

require 'bundler'
Bundler.require(:default, :test)

require_relative '../../lib/rake-builder'
require 'byebug'

describe 'C8::Project::Phony' do
  def file_double(path, exist: true, mtime: 10)
    double(path).tap do |d|
      allow(d).to receive(:directory?).and_return(false)
      allow(d).to receive(:exist?).and_return(exist)
      allow(d).to receive(:mtime).and_return(mtime)
      allow(d).to receive(:dirname).and_return(::File.dirname(path))

      allow(Pathname).to receive(:new).with(path).and_return(d)
    end
  end

  let :status_ok do
    double('status_ok').tap do |d|
      allow(d).to receive(:exitstatus).and_return(0)
    end
  end

  let :status_nok do
    double('status_nok').tap do |d|
      allow(d).to receive(:exitstatus).and_return(1)
    end
  end

  let :existing_file do
    double('existing_file').tap do |d|
      allow(d).to receive(:directory?).and_return(false)
      allow(d).to receive(:exist?).and_return(true)
    end
  end

  let :existing_directory do
    double('existing_directory').tap do |d|
      allow(d).to receive(:directory?).and_return(true)
      allow(d).to receive(:exist?).and_return(true)
    end
  end

  let :non_existing_file do
    double('non_existing_file').tap do |d|
      allow(d).to receive(:directory?).and_return(false)
      allow(d).to receive(:exist?).and_return(false)
    end
  end

  before do
    allow(Pathname).to receive(:new).with(anything).and_call_original

    allow(FileUtils).to receive(:rm).never
    allow(FileUtils).to receive(:rm_rf).never
    allow(FileUtils).to receive(:mkdir).never
    allow(FileUtils).to receive(:cp).never
    allow(FileUtils).to receive(:touch).never

    allow(C8).to receive(:sh).never
    allow(C8).to receive(:phony) do |&block|
      block.call
    end

    allow(Open3).to receive(:capture2e).never
    allow(Open3).to receive(:capture2e).with('gem', 'list').and_return(['', status_ok])
    allow(Open3).to receive(:capture2e).with('dpkg', '-s', anything).and_return(['', status_nok])
    allow(Open3).to receive(:capture2e).with('dpkg', '-s', 'pkg_b').and_return(['', status_ok])
  end

  it 'executes commands in order' do
    expect(C8).to receive(:sh).with('sudo', '-E', 'apt', 'install', 'pkg_a').and_return(nil).ordered
    expect(C8).to receive(:sh).with('sudo', '-E', 'apt', 'remove', 'pkg_b').and_return(nil).ordered
    expect(C8).to receive(:sh).with('sudo', '-E', 'apt', 'install', 'pkg_c').and_return(nil).ordered

    C8.project 'pro' do
      phony 'pho' do
        apt_install %w[pkg_a]
        apt_remove %w[pkg_b]
        apt_install %w[pkg_c]
      end
    end
  end

  it 'executes `apt install` command' do
    expect(C8).to receive(:sh).with('sudo', '-E', 'apt', 'install', 'pkg_a', 'pkg_c').and_return(nil)

    C8.project 'pro' do
      phony 'pho' do
        apt_install %w[pkg_a pkg_b pkg_c]
      end
    end
  end

  it 'executes `apt remove` command' do
    expect(C8).to receive(:sh).with('sudo', '-E', 'apt', 'remove', 'pkg_b').and_return(nil)

    C8.project 'pro' do
      phony 'pho' do
        apt_remove %w[pkg_a pkg_b pkg_c]
      end
    end
  end

  it 'executes `gem install` command' do
    allow(Open3).to receive(:capture2e).with('gem', 'list').and_return(['pkg_b', status_ok])

    expect(C8).to receive(:sh).with('sudo', '-E', 'gem', 'install', 'pkg_a').and_return(nil)
    expect(C8).to receive(:sh).with('sudo', '-E', 'gem', 'install', 'pkg_c').and_return(nil)

    C8.project 'pro' do
      phony 'pho' do
        gem_install %w[pkg_a pkg_b pkg_c]
      end
    end
  end

  it 'executes `gem uninstall` command' do
    allow(Open3).to receive(:capture2e).with('gem', 'list').and_return(["pkg_b\npkg_a\n", status_ok])

    expect(C8).to receive(:sh).with('sudo', 'gem', 'uninstall', 'pkg_a').and_return(nil)
    expect(C8).to receive(:sh).with('sudo', 'gem', 'uninstall', 'pkg_b').and_return(nil)

    C8.project 'pro' do
      phony 'pho' do
        gem_uninstall %w[pkg_a pkg_b pkg_c]
      end
    end
  end

  it 'executes `rm` command' do
    allow(Pathname).to receive(:new).with('file_a').and_return(existing_file)
    allow(Pathname).to receive(:new).with('file_b').and_return(non_existing_file)
    allow(Pathname).to receive(:new).with('file_c').and_return(existing_directory)

    expect(FileUtils).to receive(:rm).with(existing_file, verbose: true).and_return(nil)
    expect(FileUtils).to receive(:rm_rf).with(existing_directory, verbose: true).and_return(nil)

    C8.project 'pro' do
      phony 'pho' do
        rm %w[file_a file_b file_c]
      end
    end
  end

  context '`sh`' do
    def sh(*args)
      C8.project 'pro' do
        phony 'pho' do
          sh(*args)
        end
      end
    end

    it 'executes single arg command' do
      expect(C8).to receive(:sh).with('echo test').and_return(nil)

      sh 'echo test'
    end

    it 'executes multi arg command' do
      expect(C8).to receive(:sh).with('echo', 'test').and_return(nil)

      sh 'echo', 'test'
    end
  end

  context '`mkdir`' do
    def mkdir(path)
      C8.project 'pro' do
        phony 'pho' do
          mkdir path
        end
      end
    end

    it 'doesn\'t create existing directory' do
      mkdir '/tmp'
    end

    it 'creates directory when doesn\'t exist' do
      expect(FileUtils).to receive(:mkdir).with(Pathname.new('/tmp/dir'), verbose: true).and_return(nil)

      mkdir '/tmp/dir'
    end
  end

  context '`cp`' do
    def cp(src, dst)
      C8.project 'pro' do
        phony 'pho' do
          cp src, dst
        end
      end
    end

    it 'doesn\'t copy when already exist' do
      a = file_double('/tmp/a')
      b = file_double('/tmp/b')

      cp '/tmp/a', '/tmp/b'
    end

    it 'copies file when doesn\'t exist' do
      a = file_double('/tmp/a')
      b = file_double('/tmp/b', exist: false)

      expect(FileUtils).to receive(:cp).with(a, b, verbose: true).and_return(nil)
      expect(FileUtils).to receive(:touch).with(b, mtime: a.mtime).and_return(nil)

      cp '/tmp/a', '/tmp/b'
    end

    it 'copies file when outdates' do
      a = file_double('/tmp/a', mtime: 4)
      b = file_double('/tmp/b', mtime: 5)

      expect(FileUtils).to receive(:cp).with(a, b, verbose: true).and_return(nil)
      expect(FileUtils).to receive(:touch).with(b, mtime: 4).and_return(nil)

      cp '/tmp/a', '/tmp/b'
    end

    it 'creates directory when needed' do
      a = file_double('/tmp/a')
      b = file_double('/tmp/dir/b', exist: false)

      expect(FileUtils).to receive(:cp).with(a, b, verbose: true).and_return(nil)
      expect(FileUtils).to receive(:touch).with(b, mtime: a.mtime).and_return(nil)
      expect(FileUtils).to receive(:mkdir).with(Pathname.new('/tmp/dir'), verbose: true).and_return(nil)

      cp '/tmp/a', '/tmp/dir/b'
    end
  end
end
