require './api_client'

RSpec.describe ApiClient, vcr: true do
  let(:api_client) { described_class.new(api_key: api_key) }

  describe '#auctions' do
    subject { api_client.auctions }

    context 'when response is valid' do
      let(:api_key) { ENV['MICROPURCHASE_API_KEY'] }
      it 'returns an array of auctions' do
        list = subject
        expect(list).to be_a(Array)
        expect(Time.parse(list[0]['created_at'])).to be_a(Time)
      end
    end

    context 'when response is invalid' do
      let(:api_key) { 'BOGUS' }
      it 'raises an error' do
        expect { subject }.to raise_error(ApiClient::ApiError)
      end
    end
  end
end
