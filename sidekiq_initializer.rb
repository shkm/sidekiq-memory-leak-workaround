require "sidekiq"
require "./leaky_job"
require "./memory_limit_middleware"

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add(MemoryLimitMiddleware, limit: 60)
  end
end
