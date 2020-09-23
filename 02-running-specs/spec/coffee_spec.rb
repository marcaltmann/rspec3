require_relative 'coffee'

RSpec.configure do |config|
  config.filter_run_when_matching(focus: true)
  config.example_status_persistence_file_path = 'spec/examples.txt'
end

RSpec.describe 'A cup of coffee' do
  let(:coffee) { Coffee.new }

  it 'costs 1€' do
    expect(coffee.price).to eq(1.00)
  end

  context 'with milk', category: :unit do
    before { coffee.add :milk }

    it 'costs 1.25€' do
      expect(coffee.price).to eq(1.25)
    end
  end
end
