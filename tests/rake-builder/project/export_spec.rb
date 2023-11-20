require_relative '../../../lib/rake-builder'

describe 'Project::Export' do
  let :p do
    RakeBuilder::Project.new
  end

  it 'generates export object which can be used by targets' do
    exp = p.export do |t|
      t.dependencies << 'task'
      t.flags << %w[-Iinc]
      t.flags_link << %w[-lhello]
    end

    app = p.executable 'bin/app' do |t|
      exp >> t
    end

    expect(app.flags.to_a).to contain_exactly(*%w[-Iinc])
    expect(app.flags_link.to_a).to contain_exactly(*%w[-lhello])
    expect(app.dependencies.to_a).to contain_exactly(*%w[task bin])
  end
end
