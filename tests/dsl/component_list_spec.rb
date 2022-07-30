require 'rspec'
require 'rake'

require_relative '../../lib/rake-builder'

context 'ComponentList' do
  include RakeBuilder::DSL

  subject do
    component_list 'path/file.cl', %w[a b c]
  end

  it 'has path' do
    expect(subject.path).to be == Pathname.new('path/file.cl')
  end

  it 'has tracked' do
    expect(subject.tracked).to contain_exactly(*%w[a b c].collect { |x| Pathname.new(x) })
  end

  it 'has dependencies' do
    expect(subject.dependencies).to contain_exactly('path')
  end
end
