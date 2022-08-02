require 'rspec'
require 'rake'

require_relative '../lib/rake-builder'

describe 'Builder' do
  before do
    @old_out_dir = RakeBuilder.out_dir
  end

  after do
    RakeBuilder.out_dir = @old_out_dir
  end

  it 'has out_dir' do
    expect(RakeBuilder.out_dir).to be == Pathname.new('.obj')
  end

  it 'has out_dir changeable' do
    expect { RakeBuilder.out_dir = '/tmp/.obj' }.to change(RakeBuilder, :out_dir)
      .from(Pathname.new('.obj'))
      .to(Pathname.new('/tmp/.obj'))
  end
end
