RSpec.shared_examples 'it has description' do
  it 'getable' do
    expect(subject.description).to be_nil
  end

  it 'changeable' do
    expect { subject.description = 'desc' }.to change(subject, :description).from(nil).to('desc')
  end
end
