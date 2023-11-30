class LoadBalanceService

  class << self
    def next_server_url
      servers = get_servers
      server = Rails.cache.fetch('load_balancer_cache') { 0 }
      update_cache
      servers[server]
    end

    def get_servers
      Rails.cache.fetch('server_list') { Server.pluck(:url) }
    end

    private

    def update_cache
      cache = Rails.cache.read('load_balancer_cache')
      new_val = cache == 0 ? 1 : 0
      Rails.cache.write('load_balancer_cache', new_val)
    end
  end

end
