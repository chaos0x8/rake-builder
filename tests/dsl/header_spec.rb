require 'rspec'
require 'rake'

require_relative '../../lib/rake-builder'
require_relative 'common'

context 'Header' do
  include RakeBuilder::DSL

  subject do
    header 'h1.hpp' do |t|
      t.flags << %w[--std=c++20]
    end
  end

  it 'has path' do
    expect(subject.path).to be == Pathname.new('h1.hpp')
  end

  it 'has flags' do
    expect(subject.flags).to contain_exactly(*%w[--std=c++20])
  end

  it 'has dependencies' do
    expect(subject.dependencies).to contain_exactly(*%w[.obj h1.hpp])
  end

  it 'has requirements' do
    expect(subject.requirements).to contain_exactly(*%w[.obj/h1.hpp.mf .obj/h1.hpp.o])
  end

  it 'cleans itself' do
    expect(RakeBuilder::Utility).to receive(:clean).with(contain_exactly(*%w[.obj/h1.hpp.mf .obj/h1.hpp.o]))

    subject.clean
  end
end
