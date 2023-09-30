require_relative '../../../lib/rake-builder'

describe 'Project::GeneratedFile' do
  let :p do
    RakeBuilder::Project.new
  end

  context '.erb' do
    it 'allows generated file from text' do
      gf = p.generated_file 'name' do |t|
        t.erb = <<~INLINE
          var = 42
        INLINE
      end

      expect(C8.erb_eval(gf.erb)).to be == "var = 42\n"
    end

    it 'allows generated file from proc' do
      gf = p.generated_file 'name' do |t|
        val = 42

        t.erb = proc do
          <<~INLINE
            var = <%= val %>
          INLINE
        end
      end

      expect(C8.erb_eval(gf.erb)).to be == "var = 42\n"
    end

    it 'allows generated file from context class' do
      gf = p.generated_file 'name' do |t|
        t.erb = C8::ErbContext.new ({ val: 42 }), <<~INLINE
          var = <%= val %>
        INLINE
      end

      expect(C8.erb_eval(gf.erb)).to be == "var = 42\n"
    end

    it 'allows generated file from erb_context helper method' do
      gf = p.generated_file 'name' do |t|
        t.erb_context ({ val: 42 }), <<~INLINE
          var = <%= val %>
        INLINE
      end

      expect(C8.erb_eval(gf.erb)).to be == "var = 42\n"
    end

    it 'denies different types' do
      expect do
        p.generated_file 'name' do |t|
          t.erb = 42
        end
      end.to raise_error(RakeBuilder::Error::UnsuportedType)
    end
  end
end
