# frozen_string_literal: true
require "sidekiq"
require "sidekiq/api"

class LeakyJob
  include Sidekiq::Job

  THRESHOLD = 60 # MB

  def perform
    logger.info "Memory usage is #{memory_usage}MB"

    if memory_usage > THRESHOLD && process_is_sidekiq?
      logger.warn "Memory usage is above threshold; killing process."

      # "TERM" gives jobs a bit of time to finish before pushing them back to redis.
      # See https://github.com/sidekiq/sidekiq/wiki/Signals#term
      # Calling it multiple times doesn't hurt.
      Process.kill("TERM", Process.pid)

      # Note that execution will continue after sending the signal, so this particular job may still run to completion.
    else
      logger.info "Leaking..."
      leak
    end

    logger.info "Sleeping for 10 seconds."
    sleep 10

    logger.info "Finished"
  end

  def process_is_sidekiq?
    Sidekiq::ProcessSet.new.detect { |process| process["pid"] == Process.pid }
  end

  # Simulates a memory leak; globals are not garbage collected.
  def leak
    $leak ||= []

    10.times do
      $leak << " " * 1_000_000
    end
  end

  # Returns memory usage in MB
  def memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i / 1024
  end
end
