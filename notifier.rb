class Notifier
  LAST_CHECKED_KEY='18f:last_checked_at'

  attr_reader :last_checked_at

  def initialize(redis:, api_client:, emails_to_notify:)
    @redis = redis
    @api_client = api_client
    @emails_to_notify = emails_to_notify
  end

  def call(env)
    redis.set(LAST_CHECKED_KEY, Time.now.to_s)
    [200, {"Content-Type" => "text/plain"}, ["#{new_items.size} new auctions since #{last_checked_at}"]]
  end

  def new_items
    api_client.auctions.select { |auction| auction.created_at >= last_checked_at }
    last_checked_at # TODO
    []
  end

  def last_checked_at
    DateTime.parse(redis.get(LAST_CHECKED_KEY)) rescue Time.now
  end

private

  attr_reader :redis, :api_client, :emails_to_notify

end
