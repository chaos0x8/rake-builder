require_relative '../../../lib/rake-builder'

describe 'Project' do
  let :p do
    RakeBuilder::Project.new
  end

  %w[executable library_static generated_file].each do |method_name|
    context ".#{method_name}" do
      it 'creates in current directory' do
        target = p.send(method_name, 'name')
        expect(target.dependencies.to_a).to_not include('.')
      end

      it 'creates in new directory' do
        target = p.send(method_name, 'dir/name')
        expect(target.dependencies.to_a).to include('dir')
      end
    end
  end
end
