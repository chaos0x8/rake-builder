require_relative '../../../lib/rake-builder'

describe 'RakeBuilder' do
  context '.random_task' do
    it 'returns name with prefix' do
      a = RakeBuilder.random_task

      expect(a).to be =~ /^task_\w+$/
    end

    it 'returns unique name' do
      a = RakeBuilder.random_task
      b = RakeBuilder.random_task

      expect(a).to_not be == b
    end
  end
end
