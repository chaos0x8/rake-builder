require 'rspec'
require 'rake'

require_relative '../../lib/rake-builder'
require_relative 'common'

context 'GeneratedFile' do
  include RakeBuilder::DSL

  subject do
    generated_file 'file.cpp' do |t|
      t.erb = proc do
        <<~INLINE
          #include "file.hpp"
        INLINE
      end
    end
  end

  it 'has dependencies' do
    expect(subject.dependencies).to contain_exactly(*%w[.obj/file.cpp.cl])
  end

  it 'has requirements' do
    expect(subject.requirements).to contain_exactly(*%w[.obj/file.cpp.cl])
  end

  it 'cleans itself' do
    expect(RakeBuilder::Utility).to receive(:clean).with(contain_exactly(*%w[file.cpp]))

    subject.clean
  end

  it_behaves_like 'it has description'
end
