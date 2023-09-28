require_relative '../../tests/examples_base'

example_describe __FILE__ do
  %w[A B].each do |project_name|
    it "Project #{project_name} executes and produces correct output" do
      out, st = Open3.capture2e(work_dir.join("bin/project_#{project_name.downcase}").to_s)

      aggregate_failures do
        expect(st.exitstatus).to be == 0
        expect(out.chomp).to be == "Project #{project_name}"
      end
    end
  end
end
