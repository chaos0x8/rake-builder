require_relative '../../tests/examples_base'

example_describe __FILE__ do
  it 'Generated files have proper content' do
    aggregate_failures do
      expect(IO.read(source_dir.join('src/value0.hpp'))).to be == <<~TEXT
        #pragma once

        constexpr auto value0 = 32;
      TEXT

      expect(IO.read(source_dir.join('src/value1.hpp'))).to be == <<~TEXT
        #pragma once

        constexpr auto value1 = 142;
      TEXT
    end
  end

  it 'Executes and produces correct output' do
    out, st = Open3.capture2e(work_dir.join('bin/out').to_s)

    expected_output = <<~TEXT
      value0 = 32
      value1 = 142
    TEXT

    aggregate_failures do
      expect(st.exitstatus).to be == 0

      expect(out.chomp).to be == expected_output.chomp
    end
  end
end
