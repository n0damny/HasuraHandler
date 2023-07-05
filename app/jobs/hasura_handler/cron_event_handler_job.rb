module HasuraHandler
  class CronEventHandlerJob < ApplicationJob
    queue_as HasuraHandler.event_handler_job_queue

    def perform(handler_class, event)
      klass = handler_class.constantize
      handler = klass.new(HasuraHandler::CronEvent.new(event))
      handler.run
    end
  end
end
