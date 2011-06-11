class Fanfeedrb
  class Fanfeedr
    class Event < Abstract
      attr_reader :name
      #reader :description, :author, :position, :complete
      date_reader :date

      def when
        date && Date.new(date.year, date.mon, date.day)
      end

      def initialize(event, attributes = {})
        @event = event
        super(attributes)
      end

      def to_xml
        Fanfeedrb.hash_to_xml(:task, @attributes)
      end

      def inspect
        "#<#{self.class.inspect}:#{id.inspect}, event_id: #{event.id.inspect}, date: #{when.inspect} >"
      end

    end
  end


end
