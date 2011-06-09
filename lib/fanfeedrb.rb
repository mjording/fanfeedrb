require 'httparty'
module Fanfeedrb
  

  class Client
    include HTTParty
    
    def initialize(key,type)
      @auth = {:key => key, :type => type}
      @proxy = FanfeedrbProxy.new
    end
    
    def method_missing(method, *args, &block)
      @proxy.append(method, args[0])
      @opts = {:query => @proxy.options}
      if args.size > 0 && !method.to_s.eql?("post")
        execute("get")
      elsif method.to_s.match /\bget\b|\bpost\b/
        execute(method)
      else
        execute("get")
      end
    end
    
    def execute(method)
      p @proxy.url
      res = FanfeedrbResponse.construct self.class.send(method,@proxy.url,@opts)
      @proxy = FanfeedrbProxy.new
      res
    end
  end
  
  class FanfeedrbProxy
    attr_reader :options
    
    def initialize
      @keys = []; @options = {}
    end
    
    def append(key,options)
      #@options.merge!(self.default_json_options)
      @keys << key;  @options.merge!(options) if options
    end
    
    def url
      @url = "http://ffapi.fanfeedr.com/#{ENV['FANFEEDR_TYPE']}/api/" + @keys.join("/")  
    end
    protected
    
    def default_json_options
      {:api_key => @auth[:key]}
    end

  end

  class FanfeedrbResponse
    attr_reader :errors
    attr_reader :hresp
    def initialize(hash)
      hresp = []
      if hash.parsed_response.nil? || hash.parsed_response.blank?
        hresp << hash
     else
        hresp << hash.parsed_response
     end
      @hresp = hresp.flatten if !hresp.blank?

    end
    
    def self.construct(res)
      return res.class == Array ? res.collect { |item| FanfeedrbResponse.new(item) } : FanfeedrbResponse.new(res)
    end
  end
end

#Examples
#client = Fanfeedrb::Client.new(ENV['FANFEEDR_KEY'],ENV['FANFEEDR_TYPE'])
#leagues = client.statuses.show(:id => "13400589015")
#p status.errors ? status.errors : status.text

# More Examples
#user = client.users.lookup(:screen_name => "gregosuri")
#client.statuses.update.post(:status=>"Ruby Metaprogramming Rocks")
  # Your code goes here...

