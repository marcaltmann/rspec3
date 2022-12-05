require 'rack/test'
require_relative '../../../app/api'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    def parsed_body
      JSON.parse(last_response.body)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)
          expect(parsed_body).to include('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, nil, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)
          expect(parsed_body).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET /expenses/:date' do
      context 'when expenses exist on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with(Date.new(2017, 6, 10))
            .and_return([
              {
                payee: 'Starbucks',
                amount: 5.75,
                date: Date.new(2017, 6, 10)
              }
            ])
        end

        it 'returns the expense records as JSON' do
          get '/expenses/2017-06-10'
          expect(parsed_body).to eq(
            [
              {
                'payee' => 'Starbucks',
                'amount' => 5.75,
                'date' => '2017-06-10'
              }
            ]
          )
        end

        it 'responds with a 200 (OK)' do
          get '/expenses/2017-06-10'
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with(Date.new(2017, 1, 1))
            .and_return([])
        end

        it 'returns an empty array as JSON' do
          get 'expenses/2017-01-01'
          expect(parsed_body).to eq([])
        end

        it 'responds with a 200 (OK)' do
          get 'expenses/2017-01-01'
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
