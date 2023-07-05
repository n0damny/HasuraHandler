module HasuraHandler
  class CronEventJob < ApplicationJob
    queue_as HasuraHandler.event_job_queue

    def perform(event)
      HasuraHandler::CronEventProcessor.new(event).process
    end
  end
end
