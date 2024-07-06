require_relative '../../../lib/rake-builder/attr/flags_link'
require_relative '../../../lib/rake-builder/project/pkg_config'

describe RakeBuilder::Attr::FlagsLink do
  it 'parses libraries/0' do
    subject << %w[-Ldir -llib1 -llib2 abc/libabc.a]

    aggregate_failures do
      expect(subject.to_a).to contain_exactly(*%w[-Ldir -llib1 -llib2 abc/libabc.a])
      expect(subject.link).to contain_exactly(*%w[-llib1 -llib2 abc/libabc.a])
      expect(subject.each_lib.to_a).to contain_exactly(*%w[lib1 lib2 abc/libabc.a])
      expect(subject.dependencies).to contain_exactly(*%w[abc/libabc.a])
      expect(subject.link_directories).to contain_exactly(*%w[dir])
    end
  end

  it 'nil is ignored' do
    subject << %w[-llib1] << nil << %w[-llib2]

    aggregate_failures do
      expect(subject.to_a).to contain_exactly(*%w[-llib1 -llib2])
      expect(subject.link).to contain_exactly(*%w[-llib1 -llib2])
      expect(subject.each_lib.to_a).to contain_exactly(*%w[lib1 lib2])
      expect(subject.dependencies).to contain_exactly(*%w[])
      expect(subject.link_directories).to contain_exactly(*%w[])
    end
  end

  it '.<< duplicates are added at the end of list' do
    subject << %w[-Ldir -llib1 -llib2 abc/libabc.a -Ldir -llib1 abc/libabc.a]

    aggregate_failures do
      expect(subject.to_a).to be == %w[-Ldir -llib2 -llib1 abc/libabc.a]
      expect(subject.link.to_a).to be == %w[-llib2 -llib1 abc/libabc.a]
      expect(subject.each_lib.to_a).to be == %w[lib2 lib1 abc/libabc.a]
      expect(subject.dependencies.to_a).to be == %w[abc/libabc.a]
      expect(subject.link_directories).to contain_exactly(*%w[dir])
    end
  end

  it '.<< Hash raises when hash contains unsupported key' do
    expect { subject << { unknown: nil } }.to raise_error(ArgumentError)
  end

  it '.<< FlagsLink combines containers' do
    other = RakeBuilder::Attr::FlagsLink.new
    other << %w[-Ldir2 -llib2 abc/b.a]

    subject << %w[-Ldir1 -llib1 abc/a.a] << other

    aggregate_failures do
      expect(subject.to_a).to contain_exactly(*%w[-Ldir1 -Ldir2 -llib1 -llib2 abc/a.a abc/b.a])
      expect(subject.link).to contain_exactly(*%w[-llib1 -llib2 abc/a.a abc/b.a])
      expect(subject.each_lib.to_a).to contain_exactly(*%w[lib1 lib2 abc/a.a abc/b.a])
      expect(subject.dependencies).to contain_exactly(*%w[abc/a.a abc/b.a])
      expect(subject.link_directories).to contain_exactly(*%w[dir1 dir2])
    end
  end

  it '.<< PkgConfig add link flags' do
    other = RakeBuilder::PkgConfig.new('ruby')
    subject << %w[-llib1] << other

    aggregate_failures do
      expect(subject.to_a).to contain_exactly(*%w[-llib1], *other.flags_link)
      expect(subject.link).to contain_exactly(*%w[-llib1], *other.flags_link)
      expect(subject.dependencies).to contain_exactly
    end
  end

  context 'with parent' do
    let :parent do
      RakeBuilder::Attr::FlagsLink.new.tap do |p|
        p << %w[-Ldir1 -llib1 abc/a.a]
      end
    end

    let :subject do
      RakeBuilder::Attr::FlagsLink.new(parent: parent).tap do |s|
        s << %w[-Ldir2 -llib2 abc/b.a]
      end
    end

    it '.to_a respects parent' do
      expect(subject.to_a).to contain_exactly(*%w[-Ldir1 -Ldir2 -llib1 -llib2 abc/a.a abc/b.a])
    end

    it '.link respects parent' do
      expect(subject.link).to contain_exactly(*%w[-llib1 -llib2 abc/a.a abc/b.a])
    end

    it '.each_lib respects parent' do
      expect(subject.each_lib.to_a).to contain_exactly(*%w[lib1 lib2 abc/a.a abc/b.a])
    end

    it '.dependencies respects parent' do
      expect(subject.dependencies).to contain_exactly(*%w[abc/a.a abc/b.a])
    end

    it '.link_directories respects parent' do
      expect(subject.link_directories).to contain_exactly(*%w[dir1 dir2])
    end
  end
end
