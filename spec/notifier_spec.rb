require './notifier'

RSpec.describe Notifier do
  let(:redis) { double('redis') }
  let(:api_client) { double('api_client') }
  let(:emails_to_notify) { ['banana@flurgo.com'] }
  let(:last_checked_at) { Time.now - (3600*3) }

  let(:notifier) { described_class.new(redis: redis, api_client: api_client, emails_to_notify: emails_to_notify) }

  before do
    allow(notifier).to receive(:last_checked_at).and_return(last_checked_at)
    allow(notifier).to receive(:last_checked_at=)
  end

  describe '#new_items' do
    let(:auctions) do
      [
        Hashie::Mash.new({ 'created_at' => (Time.now - (3600*4)).to_datetime.to_s, 'description' => 'Too old' }),
        Hashie::Mash.new({ 'created_at' => (Time.now - (3600*2)).to_datetime.to_s, 'description' => 'New enough' }),
        Hashie::Mash.new({ 'created_at' => (Time.now - (3600*1)).to_datetime.to_s, 'description' => 'Even newer' })
      ]
    end

    before do
      allow(api_client).to receive(:auctions).and_return(auctions)
    end

    subject { notifier.new_items(since: last_checked_at) }

    it 'returns only the items newer than the timestamp' do
      result = subject
      expect(result.size).to eq(2)
      expect(result.map(&:description)).to match_array(['New enough', 'Even newer'])
    end
  end

  describe '#notify_user' do
    subject { notifier.notify_user(new_items: new_items) }

    context 'when there are new items' do
      let(:new_item_a) { double('new_item_a', title: 'Title A', summary: 'Summary A', id: '44') }
      let(:new_item_b) { double('new_item_b', title: 'Title B', summary: 'Summary B', id: '45') }
      let(:new_items) { [ new_item_a, new_item_b ] }

      it 'delivers an email to the notification list' do
        subject
        expect(Mail::TestMailer.deliveries.size).to eq(1)
        message = Mail::TestMailer.deliveries.first
        expect(message.body.to_s).to match(/1\. Title A/)
        expect(message.body.to_s).to match(/Summary A/)
        expect(message.body.to_s).to match(/2\. Title B/)
        expect(message.body.to_s).to match(/Summary B/)
      end
    end
  end
end
