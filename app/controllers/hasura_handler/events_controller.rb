require_dependency 'hasura_handler/application_controller'

module HasuraHandler
  class EventsController < ApplicationController
    before_action :check_header

    def index
      processor = HasuraHandler::EventProcessor.new(event_params.to_h)

      unless processor.event.valid?
        error_response(processor.event.errors)
        return
      end

      if HasuraHandler.async_events
        processor.process_later
        render json: { queued: true }, status: 202
        return
      end

      processor.process
      if processor.success?
        render json: { success: true }
      else
        error_response(processor.errors)
      end
    end

    private

    def error_response(errors)
      response.set_header('Retry-After', HasuraHandler.retry_after)
      render json: { success: false, errors: errors }, status: 400
    end

    def event_params
      full_params.permit(
        :id,
        :created_at,
        delivery_info: {},
        table: [
          :schema,
          :name
        ],
        trigger: [
          :name
        ],
        event: [
          :op,
          {
            session_variables: {},
            data: {}
          }
        ]
      )
    end
  end
end
