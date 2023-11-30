# spec/services/load_balance_service_spec.rb
require 'rails_helper'

RSpec.describe LoadBalanceService do
  describe '.next_server_url' do
    let(:servers) { ['http://server1.com', 'http://server2.com'] }

    before do
      allow(LoadBalanceService).to receive(:get_servers).and_return(servers)
    end

    it 'balances requests between servers' do
      server_counts = { 'http://server1.com' => 0, 'http://server2.com' => 0 }

      100.times do
        url = LoadBalanceService.next_server_url
        server_counts[url] += 1
      end
      expect(server_counts['http://server1.com']).to eq(50)
      expect(server_counts['http://server2.com']).to eq(50)
    end
  end
end
