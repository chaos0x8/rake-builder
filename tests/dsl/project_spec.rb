require 'rspec'
require 'rake'

require_relative '../../lib/rake-builder'
require_relative 'common'

context 'Project' do
  include RakeBuilder::DSL

  def peek_target(path)
    targets = subject.instance_variable_get(:@libraries) + subject.instance_variable_get(:@executables)
    targets.find { |t| t.path == RakeBuilder::Utility.to_pathname(path) }
  end

  subject do
    project do |p|
      p.executable 'exec' do |t|
        t.sources << %w[f1.cpp f2.cpp]
      end
    end
  end

  it 'has requirements' do
    expect(subject.requirements).to contain_exactly(*%w[.obj/exec.cl .obj/f1.cpp.o .obj/f1.cpp.mf .obj/f2.cpp.o
                                                        .obj/f2.cpp.mf exec])
  end

  it 'cleans itself' do
    expect(RakeBuilder::Utility).to receive(:clean).with(contain_exactly(*%w[.obj/exec.cl .obj/f1.cpp.o .obj/f1.cpp.mf .obj/f2.cpp.o
                                                                             .obj/f2.cpp.mf exec]))

    subject.clean
  end

  context 'with library' do
    subject do
      project do |p|
        p.library 'lib.a' do |t|
          t.sources << %w[l1.cpp l2.cpp]
        end

        p.executable 'exec' do |t|
          t.sources << %w[f1.cpp f2.cpp]
        end
      end
    end

    it 'has requirements' do
      expect(subject.requirements).to contain_exactly(*%w[.obj/exec.cl .obj/f1.cpp.o .obj/f1.cpp.mf .obj/f2.cpp.o .obj/f2.cpp.mf .obj/l1.cpp.o .obj/l1.cpp.mf
                                                          .obj/l2.cpp.o .obj/l2.cpp.mf .obj/lib.a.cl lib.a exec])
    end

    it 'lib.a has requirements' do
      expect(peek_target('lib.a').requirements).to contain_exactly(*%w[.obj/l1.cpp.o .obj/l1.cpp.mf .obj/l2.cpp.o
                                                                       .obj/l2.cpp.mf .obj/lib.a.cl])
    end

    it 'cleans itself' do
      expect(RakeBuilder::Utility).to receive(:clean).with(contain_exactly(*%w[.obj/exec.cl .obj/f1.cpp.o .obj/f1.cpp.mf .obj/f2.cpp.o .obj/f2.cpp.mf .obj/l1.cpp.o .obj/l1.cpp.mf
                                                                               .obj/l2.cpp.o .obj/l2.cpp.mf .obj/lib.a.cl lib.a exec]))

      subject.clean
    end
  end

  context 'with generated file' do
    let :generate_target_name do
      'gen_target_name'
    end

    subject do
      project do |p|
        p.instance_variable_set(:@generate_target_name, generate_target_name)

        %w[gen1.hpp gen2.hpp].each do |name|
          p.generated_file name do |t|
            t.erb = proc do
              <<~INLINE
                #pragma once
              INLINE
            end
          end
        end

        p.library 'lib.a' do |t|
          t.sources << %w[l1.cpp]
        end

        p.executable 'exec' do |t|
          t.sources << %w[f1.cpp]
        end
      end
    end

    it 'has requirements' do
      expect(subject.requirements).to contain_exactly(*%w[gen1.hpp gen2.hpp .obj/l1.cpp.o .obj/l1.cpp.mf .obj/lib.a.cl
                                                          lib.a .obj/f1.cpp.o .obj/f1.cpp.mf .obj/exec.cl exec])
    end

    it 'lib.a, exec has requirements ' do
      aggregate_failures do
        expect(peek_target('lib.a').requirements).to contain_exactly(*%w[gen_target_name .obj/l1.cpp.o .obj/l1.cpp.mf
                                                                         .obj/lib.a.cl])
        expect(peek_target('exec').requirements).to contain_exactly(*%w[gen_target_name .obj/l1.cpp.o .obj/l1.cpp.mf .obj/lib.a.cl
                                                                        lib.a .obj/f1.cpp.o .obj/f1.cpp.mf .obj/exec.cl])
      end
    end

    it 'libraries doesn\'t directly require generated files' do
      subject.instance_variable_get(:@libraries).each do |lib|
        expect(lib.requirements).to contain_exactly(*%w[gen_target_name .obj/l1.cpp.o .obj/l1.cpp.mf .obj/lib.a.cl])
      end
    end

    it 'executables doesn\'t directly require generated files' do
      subject.instance_variable_get(:@executables).each do |exe|
        expect(exe.requirements).to contain_exactly(*%w[gen_target_name .obj/l1.cpp.o .obj/l1.cpp.mf .obj/lib.a.cl
                                                        lib.a .obj/f1.cpp.o .obj/f1.cpp.mf .obj/exec.cl])
      end
    end

    it 'cleans itself' do
      expect(RakeBuilder::Utility).to receive(:clean).with(contain_exactly(*%w[gen1.hpp gen2.hpp .obj/l1.cpp.o .obj/l1.cpp.mf .obj/lib.a.cl
                                                                               lib.a .obj/f1.cpp.o .obj/f1.cpp.mf .obj/exec.cl exec]))

      subject.clean
    end
  end

  context 'with external' do
    let :commands do
      []
    end

    let :builder do
      RakeBuilder.instance_variable_get(:@builder)
    end

    let :path do
      Pathname.new('external')
    end

    subject do
      project do |p|
        p.external path, :git do |t|
          t.url = 'external-url'
          t.script = 'build script'
          t.products << %w[e1.hpp]
        end

        p.executable 'exec' do |t|
          t.sources << %w[f1.cpp]
        end
      end
    end

    before do
      allow(builder).to receive(:sh) do |*args|
        commands << args.join(' ')
      end

      allow(builder).to receive(:script) do |*args|
        commands << args.join(' ')
      end
    end

    context 'already complete' do
      before do
        allow(path).to receive(:glob).with('**/e1.hpp').and_return(['d/e1.hpp'])
      end

      it 'has requirements' do
        expect(subject.requirements).to contain_exactly(*%w[.obj/exec.cl .obj/f1.cpp.o .obj/f1.cpp.mf exec])
        expect(commands).to be == []
      end
    end

    context 'that contains errors' do
      it 'raise  because of missing requirements' do
        expect { subject }.to raise_error(RakeBuilder::DSL::External::Error)
        expect(commands).to be == ["git clone external-url #{path}", "cd #{path}\nbuild script\n"]
      end
    end
  end

  context 'with header' do
    subject do
      project do |p|
        p.header 'h1.hpp'
      end
    end

    it 'has requirements' do
      expect(subject.requirements).to contain_exactly(*%w[.obj/h1.hpp.mf .obj/h1.hpp.o])
    end

    it 'cleans itself' do
      expect(RakeBuilder::Utility).to receive(:clean).with(contain_exactly(*%w[.obj/h1.hpp.mf .obj/h1.hpp.o]))

      subject.clean
    end
  end

  context 'with configure' do
    subject do
      project do |p|
        p.configure :install_ruby do |t|
          t.apt_install 'ruby-dev'
        end

        p.executable 'exec' do |t|
          t.sources << %w[f1.cpp]
        end
      end
    end

    it 'has requirements' do
      expect(subject.requirements).to contain_exactly(*%w[install_ruby .obj/exec.cl .obj/f1.cpp.o .obj/f1.cpp.mf exec])
    end

    it 'exec has requirements' do
      expect(peek_target('exec').requirements).to contain_exactly(*%w[install_ruby .obj/exec.cl .obj/f1.cpp.o
                                                                      .obj/f1.cpp.mf])
    end

    it 'cleans itself' do
      expect(RakeBuilder::Utility).to receive(:clean).with(contain_exactly(*%w[.obj/exec.cl .obj/f1.cpp.o .obj/f1.cpp.mf
                                                                               exec]))

      subject.clean
    end
  end
end
