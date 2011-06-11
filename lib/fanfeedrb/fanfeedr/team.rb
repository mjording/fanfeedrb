class Fanfeedrb
  class Fanfeedr
    class Team < Abstract
      attr_reader :fanfeedr
      #reader :level, :name, :id

      def initialize(fanfeedr, attributes = {})
        @fanfeedr = fanfeedr
        super(attributes)
      end

    end
  end
end

