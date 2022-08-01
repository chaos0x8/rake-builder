require 'rspec'
require 'rake'

require_relative '../../lib/rake-builder'

describe 'Containers' do
  shared_examples 'Container' do |type|
    it "contained elements are flattened #{type}" do
      subject << 'item1' << %w[item2] << %w[item1]

      expected = %w[item1 item2].collect { |x| type.new(x) }

      expect(subject).to contain_exactly(*expected)
    end

    it 'deletes elements from container' do
      subject << %w[item1 item2 item3]

      subject.delete %w[item2]

      expected = %w[item1 item3].collect { |x| type.new(x) }

      expect(subject).to contain_exactly(*expected)
    end

    it 'can order elements at the end of container' do
      subject << %w[item1 item2 item3]
      subject.on_tail << %w[item1 item2]

      expected = %w[item3 item1 item2].collect { |x| type.new(x) }

      expect(subject.to_a).to be == expected
    end

    it 'keeps on_tail when adding other container' do
      other = subject.class.new
      other.on_tail << %w[item1 item2]

      subject << %w[item1 item2 item3] << other

      expected = %w[item3 item1 item2].collect { |x| type.new(x) }

      expect(subject.to_a).to be == expected
    end
  end

  context 'Paths' do
    subject do
      RakeBuilder::Utility::Paths.new
    end

    include_examples 'Container', Pathname
  end

  context 'StringContainer' do
    subject do
      RakeBuilder::Utility::StringContainer.new
    end

    include_examples 'Container', String
  end

  context 'Flags' do
    subject do
      RakeBuilder::Utility::Flags.new
    end

    include_examples 'Container', String
  end
end
