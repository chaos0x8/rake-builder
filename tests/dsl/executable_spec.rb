require 'rspec'
require 'rake'

require_relative '../../lib/rake-builder'
require_relative 'common'

context 'Executable' do
  shared_examples 'Executable common' do
    it 'has path' do
      expect(subject.path).to be == Pathname.new('exec')
    end

    it 'has dependencies' do
      expect(subject.dependencies).to contain_exactly(*%w[.obj/exec.cl])
    end

    it 'has requirements' do
      expect(subject.requirements).to contain_exactly(*%w[.obj/exec.cl .obj/f1.cpp.o .obj/f1.cpp.mf .obj/f2.cpp.o
                                                          .obj/f2.cpp.mf])
    end

    it 'cleans itself' do
      expect(RakeBuilder::Utility).to receive(:clean).with(contain_exactly(*%w[.obj/exec.cl .obj/f1.cpp.o
                                                                               .obj/f1.cpp.mf .obj/f2.cpp.o .obj/f2.cpp.mf exec]))

      subject.clean
    end
  end

  include RakeBuilder::DSL

  subject do
    executable 'exec' do |t|
      t.sources << %w[f1.cpp f2.cpp]
    end
  end

  include_examples 'Executable common'

  it_behaves_like 'it has description'

  context 'with library' do
    let :lib do
      library 'lib.a' do |t|
        t.sources << %w[l1.cpp l2.cpp]
      end
    end

    subject do
      executable 'exec' do |t|
        t.sources << %w[f1.cpp f2.cpp]
        t.link lib
      end
    end

    it 'has requirements' do
      expect(subject.requirements).to contain_exactly(*%w[.obj/exec.cl .obj/f1.cpp.o .obj/f1.cpp.mf .obj/f2.cpp.o
                                                          .obj/f2.cpp.mf .obj/l1.cpp.o .obj/l1.cpp.mf .obj/l2.cpp.o .obj/l2.cpp.mf .obj/lib.a.cl lib.a])
    end

    it 'cleans itself' do
      expect(RakeBuilder::Utility).to receive(:clean).with(contain_exactly(*%w[.obj/exec.cl .obj/f1.cpp.o
                                                                               .obj/f1.cpp.mf .obj/f2.cpp.o .obj/f2.cpp.mf .obj/l1.cpp.o .obj/l1.cpp.mf .obj/l2.cpp.o .obj/l2.cpp.mf .obj/lib.a.cl lib.a exec]))

      subject.clean
    end

    it_behaves_like 'it has description'
  end

  context 'with external' do
    let :ext_path do
      Pathname.new('external')
    end

    let :builder do
      RakeBuilder.instance_variable_get(:@builder)
    end

    let :ext do
      external ext_path, :git do |t|
        t.url = 'ext_url'
        t.script = 'ext_script'
        t.products << %w[e1.hpp libext.a]
      end
    end

    let :executed_commands do
      []
    end

    subject do
      executable 'exec' do |t|
        t.sources << %w[f1.cpp f2.cpp]
        t.link ext
      end
    end

    before do
      allow(builder).to receive(:sh) do |*args|
        executed_commands << args.join(' ')
      end

      allow(builder).to receive(:script) do |*args|
        executed_commands << args.join(' ')
      end
    end

    context 'already complete' do
      before do
        allow(ext_path).to receive(:glob).with('**/e1.hpp').and_return([Pathname.new('d/e1.hpp')])
        allow(ext_path).to receive(:glob).with('**/libext.a').and_return([Pathname.new('d/libext.a')])
      end

      it 'does nothing when products are available' do
        subject

        expect(executed_commands).to be == []
      end

      it 'external flags are added' do
        expect(subject.flags).to contain_exactly(*%w[-Id])
      end

      it 'external link_flags are added' do
        expect(subject.link_flags).to contain_exactly(*%w[-Ld -lext])
      end

      include_examples 'Executable common'

      it_behaves_like 'it has description'
    end

    context 'that contains errors' do
      it 'raises when files are not produced' do
        expect { subject }.to raise_error(RakeBuilder::DSL::External::Error)
        expect(executed_commands).to be == ["git clone ext_url #{ext_path}", "cd #{ext_path}\next_script\n"]
      end
    end
  end
end
