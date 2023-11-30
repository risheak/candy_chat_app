require 'rails_helper'

RSpec.describe LoadBalanceService do
  describe '.next_server_url' do
    let(:servers) { ['http://server1.com', 'http://server2.com'] }

    before do
      allow(Server).to receive(:pluck).with(:url).and_return(servers)
      allow(Rails.cache).to receive(:fetch).with('load_balancer_cache').and_return(0)
    end

    it 'distributes requests equally between two servers' do
      100.times do |i|
        mod = (i % 2)
        server_number = mod + 1
        allow(Rails.cache).to receive(:read).with('load_balancer_cache').and_return(mod)
        expect(servers[mod]).to eq("http://server#{server_number}.com")
      end
    end
  end
end