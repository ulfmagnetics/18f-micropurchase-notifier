require 'json'

class ApiClient
  API_BASE_URL='https://micropurchase.18f.gov/api/v0'

  class ApiError < StandardError; end

  def initialize(api_key:)
    @api_key = api_key
  end

  def auctions
    response = get('/auctions')
    body = JSON.parse(response.body)['auctions']
  rescue => ex
    raise ApiError, "Couldn't fetch list of auctions (response.code=#{response.code})"
  end

private

  attr_reader :api_key

  def get(path)
    RestClient.get("#{API_BASE_URL}/#{path}", {:accept => :json, 'HTTP_API_KEY' => api_key})
  end
end
