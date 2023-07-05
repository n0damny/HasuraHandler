module HasuraHandler
  class CronEvent
    attr_reader :id,
                :trigger,
                :event,
                :payload,
                :scheduled_time,
                :raw_event,
                :errors

    def initialize(event)
      @id = event['id']
      @trigger = event['name']
      @raw_event = @event = event
      @payload = event['payload']
      @scheduled_time = event['scheduled_time']
      @errors = {}

      %i[validate_simple_fields validate_trigger validate_event]
        .each { |check| self.send(check) }
    end

    def valid?
      @errors.blank?
    end

    private

    def validate_simple_fields
      %i[id scheduled_time]
      .each do |field|
        @errors[field.to_s] = 'missing' unless self.send(field).present?
      end
    end

    def validate_trigger
      string_fields?(@raw_event, 'trigger', ['name'])
    end

    def validate_event
      unless @event.is_a?(Hash)
        @errors['event'] = 'not a hash'
        return
      end

      @errors['event.payload'] = 'not a hash' unless @event['payload'].is_a?(Hash)
    end

    def string_fields?(field, error_key, subfields)
      subfields.each do |subfield|
        unless field[subfield].present? && field[subfield].is_a?(String)
          errors["#{error_key}.#{subfield}"] = 'missing'
        end
      end
    end
  end
end
