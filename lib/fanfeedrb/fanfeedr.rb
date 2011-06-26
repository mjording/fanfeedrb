require 'cgi'
require 'crack/json'

class Fanfeedrb
  class Fanfeedr
#/silver/api/leagues/20f0857f-3c43-5f50-acfc-879f838ee853/events/4dd1704b-a712-511c-b947-8c8f03ea3200?api_key=vbxctn5sn8x7jz644evkrhtc
    ADDRESS = "ffapi.fanfeedr.com"
    BASE_PATH = "/#{Fanfeedrb.config['api_plan']}/api/"
    #SEARCH_KEYS = %w(label type state requester owner mywork id includedone)
    class Error < Fanfeedrb::Error; end

    attr_reader :token,:plan

    def initialize(token,plan, ssl = false)
      @token = token
      @plan = plan 
      @ssl = ssl
    end

    def ssl?
      @ssl
    end
    def http
      unless @http
        if ssl?
          require 'net/https'
          @http = Net::HTTP.new(ADDRESS, Net::HTTP.https_default_port)
          @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          @http.use_ssl = true
        else
          require 'net/http'
          @http = Net::HTTP.new(ADDRESS)
        end
      end
      @http
    end

    def request(method, path, *args)
      headers = {
        #"api_key" => @token,
        "Accept"         => "application/json",
        "Content-type"   => "application/json"
      }
      http # trigger require of 'net/http'
      klass = Net::HTTP.const_get(method.to_s.capitalize)
      p klass
      path << "?api_key=#{CGI.escape(@token)}"
      p path
      http.request(klass.new("#{BASE_PATH}#{path}", headers), *args)
    end
    def request_json(method, path, *args)
      response = request(method,path,*args)
      raise response.inspect if response["Content-type"].split(/; */).first != "application/json"
      hash = Crack::JSON.parse(response.body)
      if hash.class == Hash && hash["message"] && (response.code.to_i >= 400 || hash["success"] == "false")
        raise Error, hash["message"], caller
      end
      hash
    end

    def get_json(path)
      p path
      request_json(:get, path)
    end

    def league(id)
      League.new(self,get_json("/leagues/#{id}"))
    end
    #def conference(id)
      #Conference.new(self,get_json("/conferences/#{id}"))
    #end

     class Abstract
      def initialize(attributes = {})
        @attributes = {}
        (attributes || {}).each do |k,v|
          if respond_to?("#{k}=")
            send("#{k}=", v)
          else
            @attributes[k.to_s] = v
          end
        end
        yield self if block_given?
      end

      def self.reader(*methods)
        methods.each do |method|
          define_method(method) { @attributes[method.to_s] }
        end
      end

      def self.date_reader(*methods)
        methods.each do |method|
          define_method(method) do
            value = @attributes[method.to_s]
            value.kind_of?(String) ? Date.parse(value) : value
          end
        end
      end

      def self.accessor(*methods)
        reader(*methods)
        methods.each do |method|
          define_method("#{method}=") { |v| @attributes[method.to_s] = v }
        end
      end

      def id
        id = @attributes['id'] and Integer(id)
      end

      def to_xml
        Fanfeedrb.hash_to_xml(self.class.name.split('::').last.downcase, @attributes)
      end

    end
  end
end


require 'fanfeedrb/fanfeedr/league'
require 'fanfeedrb/fanfeedr/event'
require 'fanfeedrb/fanfeedr/content'
require 'fanfeedrb/fanfeedr/conference'
require 'fanfeedrb/fanfeedr/team'









