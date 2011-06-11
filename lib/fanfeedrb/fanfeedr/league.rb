class Fanfeedrb
  class Fanfeedr
    class League < Abstract
      attr_reader :fanfeedr
      reader :gender, :levels, :sport, :name

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





    end
  end
end
