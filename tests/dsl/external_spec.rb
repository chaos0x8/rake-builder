require 'rspec'
require 'rake'

require_relative '../../lib/rake-builder'
require_relative 'common'

context 'External' do
  include RakeBuilder::DSL

  subject do
    external 'some-library', :git do |t|
    end
  end

  it 'doesn\'t have path' do
    expect(subject).to_not respond_to(:path)
  end

  it 'has dependencies' do
    expect(subject.dependencies).to contain_exactly(*%w[])
  end

  it 'doesn\'t have requirements' do
    expect(subject).to_not respond_to(:requirements)
  end

  it 'doesn\'t have clean' do
    expect(subject).to_not respond_to(:clean)
  end
end
