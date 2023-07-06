require_dependency 'hasura_handler/application_controller'

module HasuraHandler
  class CronEventsController < ApplicationController
    before_action :check_header

    def index
      processor = HasuraHandler::CronEventProcessor.new(raw_params)

      unless processor.event.valid?
        error_response(processor.event.errors)
        return
      end

      if HasuraHandler.async_events
        if processor.process_later
          render json: { queued: true }, status: 202
        else
          error_response(processor.errors)
        end
        return
      end

      processor.process
      if processor.success?
        render json: { success: true }
      else
        error_response(processor.errors)
      end
    end
  end
end
