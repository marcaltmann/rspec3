require_relative('sandwich')

RSpec.describe 'An ideal sandwich' do
  def sandwich
    Sandwich.new('delicious', [])
  end

  it 'is delicious' do
    taste = sandwich.taste

    expect(taste).to eq('delicious')
  end

  it 'lets me add toppings' do
    s = sandwich

    s.toppings << 'cheese'
    toppings = s.toppings

    expect(toppings).not_to be_empty
  end
end
