require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])
Dotenv.load if ENV['RACK_ENV'] == 'development'

redis_uri = URI.parse(ENV['REDIS_URL'])
redis = Redis.new(host: redis_uri.host, port: redis_uri.port, password: redis_uri.password)

require './api_client'
require './notifier'
api_client = ApiClient.new(api_key: ENV['MICROPURCHASE_API_KEY'])
run Notifier.new(
  redis: redis,
  api_client: api_client,
  emails_to_notify: (ENV['EMAILS_TO_NOTIFY'] || "").split(',')
)
