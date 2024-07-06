require_relative '../../../lib/rake-builder/attr/flags_compile'
require_relative '../../../lib/rake-builder/project/pkg_config'

describe RakeBuilder::Attr::FlagsCompile do
  it 'parses include directories/0' do
    subject << %w[flag0 -Isrc]

    aggregate_failures do
      expect(subject.to_a).to contain_exactly(*%w[flag0 -Isrc])
      expect(subject.include_directories).to contain_exactly(*%w[src])
    end
  end

  it 'parses include directories/1' do
    subject << [%w[flag0], { I: %w[src] }]

    aggregate_failures do
      expect(subject.to_a).to contain_exactly(*%w[flag0 -Isrc])
      expect(subject.include_directories).to contain_exactly(*%w[src])
    end
  end

  it 'nil is ignored' do
    subject << %w[flag0 -Isrc] << nil << %w[-Iinc]

    aggregate_failures do
      expect(subject.to_a).to contain_exactly(*%w[flag0 -Isrc -Iinc])
      expect(subject.include_directories).to contain_exactly(*%w[src inc])
    end
  end

  instance_variable_set(:@parse_cpp_standard_idx, 0)

  shared_examples 'parse c++ standard' do |input:, expected:|
    idx = instance_variable_get(:@parse_cpp_standard_idx)
    instance_variable_set(:@parse_cpp_standard_idx, idx + 1)

    it "parse c++ standard/#{idx}" do
      subject << input

      aggregate_failures do
        expect(subject.to_a).to contain_exactly("--std=c++#{expected}")
        expect(subject.cpp_standard.value).to be == expected
      end
    end
  end

  include_examples 'parse c++ standard',
                   input: %w[--std=c++11 --std=c++17 --std=c++14],
                   expected: '17'
  include_examples 'parse c++ standard',
                   input: %w[--std=c++20 --std=c++2a --std=c++19],
                   expected: '20'
  include_examples 'parse c++ standard',
                   input: %w[--std=c++2a --std=c++17],
                   expected: '2a'
  include_examples 'parse c++ standard',
                   input: %w[--std=c++2a --std=c++2b --std=c++17],
                   expected: '2b'

  include_examples 'parse c++ standard',
                   input: [%w[--std=c++11 --std=c++17 --std=c++14], { std: 20 }],
                   expected: '20'
  include_examples 'parse c++ standard',
                   input: [%w[--std=c++11 --std=c++17], { std: 14 }],
                   expected: '17'

  include_examples 'parse c++ standard',
                   input: %w[--std=c++11 --std=c++17 --std=c++14 --std=c++98],
                   expected: '17'
  include_examples 'parse c++ standard',
                   input: [%w[--std=c++11 --std=c++17 --std=c++14], { std: 98 }],
                   expected: '17'

  it '.<< duplicates are added at the end of list' do
    subject << %w[-Idir0 -Idir1 -Idir0]

    aggregate_failures do
      expect(subject.to_a).to be == %w[-Idir1 -Idir0]
      expect(subject.include_directories.to_a).to be == %w[dir1 dir0]
    end
  end

  it '.<< Hash raises when hash contains unsupported key' do
    expect { subject << { unknown: nil } }.to raise_error(ArgumentError)
  end

  it '.<< FlagsCompile combines containers' do
    other = RakeBuilder::Attr::FlagsCompile.new
    other << %w[-Idir1 --std=c++11]

    subject << %w[-Idir0 --std=c++14] << other

    aggregate_failures do
      expect(subject.to_a).to contain_exactly(*%w[-Idir0 -Idir1 --std=c++14])
      expect(subject.include_directories).to contain_exactly(*%w[dir0 dir1])
      expect(subject.cpp_standard.value).to be == '14'
    end
  end

  it '.<< PkgConfig add compile flags' do
    other = RakeBuilder::PkgConfig.new('ruby')
    subject << %w[-Idir0 --std=c++14] << other

    other_dirs = other.flags_compile.collect { |f| f.sub(/^-I/, '') }

    aggregate_failures do
      expect(subject.to_a).to contain_exactly(*%w[-Idir0 --std=c++14], *other.flags_compile)
      expect(subject.include_directories).to contain_exactly(*%w[dir0], *other_dirs)
      expect(subject.cpp_standard.value).to be == '14'
    end
  end

  context 'with parent' do
    let :parent do
      RakeBuilder::Attr::FlagsCompile.new.tap do |p|
        p << %w[--std=c++20 -Idir0]
      end
    end

    let :subject do
      RakeBuilder::Attr::FlagsCompile.new(parent: parent).tap do |s|
        s << %w[--std=c++17 -Idir1]
      end
    end

    it '.to_a respects parent' do
      expect(subject.to_a).to contain_exactly(*%w[--std=c++20 -Idir0 -Idir1])
    end

    it '.cpp_standard respects parent' do
      expect(subject.cpp_standard.value).to be == '20'
    end

    it '.include_directories respects parent' do
      expect(subject.include_directories).to contain_exactly(*%w[dir0 dir1])
    end
  end
end
