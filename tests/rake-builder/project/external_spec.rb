require_relative '../../../lib/rake-builder'

describe 'Project::External' do
  let :p do
    RakeBuilder::Project.new
  end

  context '.export' do
    it 'export object depends on external target' do
      ext = p.external 'abc'

      exp = ext.export

      expect(exp.dependencies).to contain_exactly(*%w[abc])
      expect(exp.flags).to contain_exactly
      expect(exp.flags_link).to contain_exactly
    end
  end
end
