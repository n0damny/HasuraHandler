# module HasuraHandler
  class HasuraHandler::CronEventProcessor < HasuraHandler::EventProcessor
    attr_accessor :event, :errors
    
    def initialize(event)
      @event = HasuraHandler::CronEvent.new(event)
      @errors = {}
    end

    def process_later
      unless event_handlers.present?
        log_missing_handler
        return
      end

      HasuraHandler::CronEventJob.perform_later(@event.raw_event)
    end

    def process
      unless event_handlers.present?
        log_missing_handler
        return
      end

      event_handlers.each do |handler_class|
        if HasuraHandler.fanout_events
          HasuraHandler::CronEventHandlerJob.perform_later(handler_class.to_s, @event.raw_event)
        else
          handler = handler_class.new(@event)
          handler.run
        end
      end
    end
  end
# end

