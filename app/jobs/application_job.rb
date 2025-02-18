class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  retry_on StandardError, attempts: 2 do |_job, _exception|
    # Log error, do nothing, etc.
  end

  JobTimeoutError = Class.new(StandardError)

  around_perform do |_job, block|
    # Timeout jobs after 10 minutes
    Timeout.timeout(2.minutes, JobTimeoutError) do
      block.call
    end
  end
end
