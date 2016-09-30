class Notifier
  LAST_CHECKED_KEY='18f:last_checked_at'

  def initialize(redis:, api_client:, emails_to_notify:)
    @redis = redis
    @api_client = api_client
    @emails_to_notify = emails_to_notify
  end

  def call(env)
    timestamp = last_checked_at
    items = new_items(since: timestamp)
    notify_user(new_items: items)
    last_checked_at = Time.now

    [200, {"Content-Type" => "text/plain"}, ["#{items.size} new auctions since #{timestamp}"]]
  end

  def new_items(since:)
    api_client.auctions.select { |auction| DateTime.parse(auction.created_at) >= since.to_datetime }
  end

  def notify_user(new_items:)
    return unless new_items.any?
    mail = Mail.new
    mail.from = "no-reply@18f-micropurchase-notifier.herokuapp.com"
    mail.to = emails_to_notify
    mail.subject = "#{new_items.size} new micropurchase auctions have been posted"
    mail.body = render_items_as_text(items: new_items)
    mail.deliver!
  end

private

  attr_accessor :last_checked_at
  attr_reader :redis, :api_client, :emails_to_notify

  def last_checked_at
    return DateTime.parse(ENV['DEBUG_LAST_CHECKED_KEY']) if !ENV['DEBUG_LAST_CHECKED_KEY'].nil?
    DateTime.parse(redis.get(LAST_CHECKED_KEY)) rescue Time.now
  end

  def last_checked_at=(timestamp)
    redis.set(LAST_CHECKED_KEY, timestamp.to_s)
  end

  def render_items_as_text(items:)
    items.each_with_index.map do |item, i|
      lines = []
      lines << "#{i+1}. #{item.title}"
      lines << "https://micropurchase.18f.gov/auctions/#{item.id}"
      lines << ""
      lines << item.summary
      lines.join('\n')
    end.join('\n---\n\n')
  end
end
