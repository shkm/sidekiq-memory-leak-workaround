require "sidekiq"
class MemoryLimitMiddleware
  include Sidekiq::ServerMiddleware
  DEFAULT_LIMIT = 800

  def initialize(options = {})
    @limit = options.fetch(:limit, DEFAULT_LIMIT)
  end


  def call(job_instance, job_payload, queue)
    mem = memory_usage
    logger.info "Memory usage is #{mem}MB"

    if mem > limit
      logger.warn "Memory usage is above limit; killing process."

      # "TERM" gives jobs a bit of time to finish before pushing them back to redis.
      # See https://github.com/sidekiq/sidekiq/wiki/Signals#term
      # Calling it multiple times doesn't hurt.
      Process.kill("TERM", Process.pid)
      # Note that execution will continue after sending the signal, so this particular job may still run to completion.
    end

    yield
  end

  private

  attr_reader :limit

  # Returns memory usage in MB
  def memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i / 1024
  end
end
