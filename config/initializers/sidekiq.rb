Sidekiq.configure_server do |config|
  config.redis = { url: "#{REDIS_URL}:7520/0" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "#{REDIS_URL}:7520/0" }
end
