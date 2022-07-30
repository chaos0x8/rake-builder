require 'rspec'
require 'rake'

require_relative '../../lib/rake-builder'
require_relative 'common'

context 'Library' do
  include RakeBuilder::DSL

  subject do
    library 'lib.a' do |t|
      t.sources << %w[f1.cpp f2.cpp]
    end
  end

  it 'has path' do
    expect(subject.path).to be == Pathname.new('lib.a')
  end

  it 'has dependencies' do
    expect(subject.dependencies).to contain_exactly(*%w[.obj/lib.a.cl])
  end

  it 'has requirements' do
    expect(subject.requirements).to contain_exactly(*%w[.obj/lib.a.cl .obj/f1.cpp.o .obj/f1.cpp.mf .obj/f2.cpp.o
                                                        .obj/f2.cpp.mf])
  end

  it 'cleans itself' do
    expect(RakeBuilder::Utility).to receive(:clean).with(contain_exactly(*%w[.obj/lib.a.cl .obj/f1.cpp.o .obj/f1.cpp.mf .obj/f2.cpp.o .obj/f2.cpp.mf
                                                                             lib.a]))

    subject.clean
  end

  it_behaves_like 'it has description'
end
