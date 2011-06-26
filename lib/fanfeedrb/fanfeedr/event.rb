class Fanfeedrb
  class Fanfeedr
    class Event < Abstract
      attr_reader :name
      reader :status, :home_team, :season_year, :season_type, :id, :away_team
      #reader :description, :author, :position, :complete
      date_reader :date

      def happenin
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
        "#<#{self.class.inspect}:#{id.inspect}, event_id: #{id.inspect}, date: #{happenin.inspect} >"
      end

    end
  end


end
