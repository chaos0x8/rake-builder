RSpec.shared_examples 'it has description' do
  it 'getable' do
    expect(subject.description).to be_nil
  end

  it 'changeable' do
    expect { subject.description = 'desc' }.to change(subject, :description).from(nil).to('desc')
  end
end

RSpec.shared_examples 'pkg_config' do |*types|
  if types.include? :flags
    it 'has pkg_config for flags' do
      expect(RakeBuilder::Utility).to receive(:pkg_config).with('--cflags', 'pkg')
      allow(RakeBuilder::Utility).to receive(:pkg_config).with('--libs', 'pkg')

      subject.pkg_config 'pkg'
    end
  else
    it 'doesn\'t have pkg_config for flags' do
      expect(RakeBuilder::Utility).to receive(:pkg_config).with('--cflags', 'pkg').never
      allow(RakeBuilder::Utility).to receive(:pkg_config).with('--libs', 'pkg')

      subject.pkg_config 'pkg'
    end
  end

  if types.include? :link_flags
    it 'has pkg_config for link_flags' do
      allow(RakeBuilder::Utility).to receive(:pkg_config).with('--cflags', 'pkg')
      expect(RakeBuilder::Utility).to receive(:pkg_config).with('--libs', 'pkg')

      subject.pkg_config 'pkg'
    end
  else
    it 'doesn\'t have pkg_config for link_flags' do
      allow(RakeBuilder::Utility).to receive(:pkg_config).with('--cflags', 'pkg')
      expect(RakeBuilder::Utility).to receive(:pkg_config).with('--libs', 'pkg').never

      subject.pkg_config 'pkg'
    end
  end
end
