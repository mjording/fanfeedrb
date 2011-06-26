class Fanfeedrb
  class Fanfeedr
    class League < Abstract
      attr_reader :fanfeedr
      reader :gender, :levels, :sport, :name, :id


      def initialize(fanfeedr, attributes = {})
        p "league attr: #{attributes}"
        @fanfeedr = fanfeedr
        super(attributes)
      end

      def conference(conference_id)
        raise Error, "No conference id given" if conference_id.to_s.empty?
        Conference.new(self,fanfeedr.get_json("/conferences/#{conference_id}"))
      end
      def conferences(*args)
        path = "/leagues/#{id}/conferences"
        #path << "?api_key=#{CGI.escape(Fanfeedrb.config['api_token'])}" 
        #if filter
        response = fanfeedr.get_json(path)
        [response].flatten.compact.map {|s| Conference.new(self,s)}
      end
      def event(event_id)
        raise Error, "No conference id given" if event_id.to_s.empty?
        Event.new(self,fanfeedr.get_json("/events/#{event_id}"))
      end

      def events(startdate = Time.now, enddate = Time.now)
         today = startdate.strftime("%m/%d/%Y") == enddate.strftime("%m/%d/%Y") && startdate.strftime("%m/%d/%Y") == Time.now.strftime("%m/%d/%Y")


         path = "/leagues/#{id}/events/today"
        #today = startdate.strftime("%m/%d/%Y") == enddate.strftime("%m/%d/%Y") && startdate.strftime("%m/%d/%Y") == Time.now.strftime("%m/%d/%Y")

        #subpath =        #path << "?api_key=#{CGI.escape(Fanfeedrb.config['api_token'])}" 
        #if filter
        response = fanfeedr.get_json(path)

      end





    end
  end
end
