RSpec.shared_examples 'it has description' do
  it 'getable' do
    expect(subject.description).to be_nil
  end

  it 'changeable' do
    expect { subject.description = 'desc' }.to change(subject, :description).from(nil).to('desc')
  end
end

RSpec.shared_examples 'pkg_config' do |*types, configures: {}|
  context 'pkg_config' do
    let :unexpected_task do
      double('unexpected_task')
    end

    before do
      allow(RakeBuilder::Utility).to receive(:pkg_config).with('--cflags', 'pkg')
      allow(RakeBuilder::Utility).to receive(:pkg_config).with('--libs', 'pkg')
      allow(Rake::Task).to receive(:[]).and_return(unexpected_task)
      allow(unexpected_task).to receive(:invoke)
    end

    if types.include? :flags
      it 'is called for flags' do
        expect(RakeBuilder::Utility).to receive(:pkg_config).with('--cflags', 'pkg')

        subject.pkg_config 'pkg'
      end
    else
      it 'isn\'t called for flags' do
        expect(RakeBuilder::Utility).to receive(:pkg_config).with('--cflags', 'pkg').never

        subject.pkg_config 'pkg'
      end
    end

    if types.include? :link_flags
      it 'is called for link_flags' do
        expect(RakeBuilder::Utility).to receive(:pkg_config).with('--libs', 'pkg')

        subject.pkg_config 'pkg'
      end
    else
      it 'isn\'t called for link_flags' do
        expect(RakeBuilder::Utility).to receive(:pkg_config).with('--libs', 'pkg').never

        subject.pkg_config 'pkg'
      end
    end

    if configures.size > 0
      it 'invokes configures before' do
        configures.each do |conf|
          double("task_#{conf}").tap do |task_double|
            allow(Rake::Task).to receive(:[]).with(conf).and_return(task_double)
            expect(task_double).to receive(:invoke).ordered
          end
        end

        expect(unexpected_task).to receive(:invoke).never
        expect(RakeBuilder::Utility).to receive(:pkg_config).at_least(1).ordered

        subject.pkg_config 'pkg'
      end
    else
      it 'doesn\'t invoke configures before' do
        expect(unexpected_task).to receive(:invoke).never
        expect(RakeBuilder::Utility).to receive(:pkg_config).at_least(1).ordered

        subject.pkg_config 'pkg'
      end
    end
  end
end
