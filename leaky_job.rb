# frozen_string_literal: true
require "sidekiq"

class LeakyJob
  include Sidekiq::Job

  def perform
    leak

    logger.info "Sleeping for 10 seconds."
    sleep 10
    logger.info "Finished"
  end

  private

  # Simulates a memory leak; globals are not garbage collected.
  def leak
    $leak ||= []

    10.times do
      $leak << " " * 1_000_000
    end
  end
end
