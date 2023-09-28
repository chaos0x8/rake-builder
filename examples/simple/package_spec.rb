require_relative '../../tests/examples_base'

example_describe __FILE__ do
  it 'Executes and produces correct output' do
    out, st = Open3.capture2e(work_dir.join('bin/out').to_s)

    aggregate_failures do
      expect(st.exitstatus).to be == 0
      expect(out.chomp).to be == 'Hello world!'
    end
  end
end
