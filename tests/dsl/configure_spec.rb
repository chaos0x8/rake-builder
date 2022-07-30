require 'rspec'
require 'rake'

require_relative '../../lib/rake-builder'
require_relative 'common'

context 'Phony' do
  include RakeBuilder::DSL

  subject do
    configure :install_ruby do |t|
      expect(t).to respond_to(:apt_install)
      expect(t).to respond_to(:apt_remove)
      expect(t).to respond_to(:gem_install)
      expect(t).to respond_to(:gem_uninstall)
    end
  end

  it 'has name' do
    expect(subject.name).to be == :install_ruby
  end

  it 'doesn\'t have path' do
    expect(subject).to_not respond_to(:path)
  end

  it 'has empty dependencies' do
    expect(subject.dependencies).to contain_exactly
  end

  it 'doesn\'t have requirements' do
    expect(subject).to_not respond_to(:requirements)
  end

  it 'doesn\'t have clean' do
    expect(subject).to_not respond_to(:clean)
  end

  it_behaves_like 'it has description'
end
