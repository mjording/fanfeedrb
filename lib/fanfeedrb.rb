class Fanfeedrb
  class Error < RuntimeError
  end

  autoload :Runner,  'fanfeedrb/runner'
  autoload :Fanfeedr, 'fanfeedrb/fanfeedr'
  autoload :League, 'fanfeedrb/fanfeedr/league'
  autoload :Event, 'fanfeedrb/fanfeedr/event'
  autoload :Content, 'fanfeedrb/fanfeedr/content'
  autoload :Conference, 'fanfeedrb/fanfeedr/conference'



  def self.config
    @config ||= {'api_token' => ENV["FANFEEDR_API_TOKEN"]}.merge(
      if File.exist?(path = File.expand_path('~/.fanfeedr.yml'))
        YAML.load_file(path)
      end || {}
    )
  end

  def self.hash_to_xml(root, attributes)
    require 'cgi'
    xml = "<#{root}>"
    attributes.each do |k,v|
      if v.kind_of?(Hash)
        xml << hash_to_xml(k, v)
      else
        xml << "<#{k}>#{CGI.escapeHTML(v.to_s)}</#{k}>"
      end
    end
    xml << "</#{root}>"
  end

  def self.run(argv)
    Runner.new(argv).run
  end

  attr_reader :directory

  def initialize(path = '.')
    @lang = 'en'
    @directory = File.expand_path(path)
    #until File.directory?(File.join(@directory,'features'))
      #if @directory == File.dirname(@directory)
        #raise Error, 'not found.  Make sure you have a features/ directory.', caller
      #end
      #@directory = File.dirname(@directory)
    #end
  end

  def feedr_path(*subdirs)
    File.join(@directory,'fanfeedr',*subdirs)
  end

  def config_file
    feedr_path('fanfeedr.yml')
  end

  def config
    @config ||= File.exist?(config_file) && YAML.load_file(config_file) || {}
    self.class.config.merge(@config)
  end

  def new_story(attributes = {}, &block)
    attributes = attributes.inject('requested_by' => real_name) do |h,(k,v)|
      h.update(k.to_s => v)
    end
    .new_story(attributes, &block)
  end

  def stories(*args)
    project.stories(*args)
  end

  def name
    league.name
  end

  def iteration_length
    project.iteration_length
  end

  def point_scale
    project.point_scale
  end

  def week_start_day
    project.week_start_day
  end

  def deliver_all_finished_stories
    project.deliver_all_finished_stories
  end

  #def parse(story)
    #require 'cucumber'
    #Cucumber::FeatureFile.new(story.url, story.to_s).parse(
      #Cucumber::Cli::Options.new,
      #{}
    #)
  #end

  def league_id
    config["league_id"] || (self.class.config["leagues"]||{})[File.basename(@directory)]
  end

  def leagues
    
  end

  def league
    @league ||= Dir.chdir(@directory) do
      unless token = config['api_token']
        raise Error, 'echo api_token: ... > ~/.fanfeedr.yml'
      end
      unless plan = config['api_plan']
        raise Error, 'echo api_plan: ... > ~/.fanfeedr.yml'
      end
      unless id = league_id
        raise Error, 'echo league_id: ... > fanfeedr/fanfeedr.yml'
      end
      ssl = config['ssl']
      Fanfeedr.new(token, plan, ssl).league(id)
    end
  end

  def events
    
  end
 
  def scenario_word
    #require 'cucumber'
    #Gherkin::I18n::LANGUAGES[@lang]['scenario']
    if @lang == 'en'
      'Scenario'
    else
      raise Error, 'Sorry, no internationalization support (yet)'
    end

  end

  def format
    (config['format'] || :tag).to_sym
  end

  def local_features
    Dir[features_path('**','*.feature')].map {|f|feature(f)}.select {|f|f.pushable?}
  end

  def scenario_features (excluded_states = %w()) #(excluded_states = %w(unscheduled unstarted))
    project.stories(scenario_word, :includedone => true).reject do |s|
      Array(excluded_states).map {|state| state.to_s}.include?(s.current_state)
    end.select do |s|
      s.to_s =~ /^\s*#{Regexp.escape(scenario_word)}:/
    end
  end

  def feature(string)
    string.kind_of?(Feature) ? string : Feature.new(self,string)
  end

  def story(string)
    feature(string).story
  end

  protected


end

  #class Client
    #def initialize(key,type)
      #@auth = {:key => key, :type => type}
      #@proxy = FanfeedrbProxy.new
    #end
    
    #def method_missing(method, *args, &block)
      #@proxy.append(method, args[0])
      #@opts = {:query => @proxy.options}
      #if args.size > 0 && !method.to_s.eql?("post")
        #execute("get")
      #elsif method.to_s.match /\bget\b|\bpost\b/
        #execute(method)
      #else
        #execute("get")
      #end
    #end
    
    #def execute(method)
      #p @proxy.url
      #res = FanfeedrbResponse.construct self.class.send(method,@proxy.url,@opts)
      #@proxy = FanfeedrbProxy.new
      #res
    #end
  #end
  
  #class FanfeedrbProxy
    #attr_reader :options
    
    #def initialize
      #@keys = []; @options = {}
    #end
    
    #def append(key,options)
      ##@options.merge!(self.default_json_options)
      #@keys << key;  @options.merge!(options) if options
    #end
    
    #def url
      #@url = "http://ffapi.fanfeedr.com/#{ENV['FANFEEDR_TYPE']}/api/" + @keys.join("/")  
    #end
    #protected
    
    #def default_json_options
      #{:api_key => @auth[:key]}
    #end

  #end

  #class FanfeedrbResponse
    #attr_reader :errors
    #attr_reader :hresp
    #def initialize(hash)
      #hresp = []
      #if hash.parsed_response.nil? || hash.parsed_response.blank?
        #hresp << hash
     #else
        #hresp << hash.parsed_response
     #end
      #@hresp = hresp.flatten if !hresp.blank?

    #end
    
    #def self.construct(res)
      #return res.class == Array ? res.collect { |item| FanfeedrbResponse.new(item) } : FanfeedrbResponse.new(res)
    #end
  #end
#end

##Examples
##client = Fanfeedrb::Client.new(ENV['FANFEEDR_KEY'],ENV['FANFEEDR_TYPE'])
##leagues = client.statuses.show(:id => "13400589015")
##p status.errors ? status.errors : status.text
#http://ffapi.fanfeedr.com/silver/api/leagues/20f0857f-3c43-5f50-acfc-879f838ee853/events/4dd1704b-a712-511c-b947-8c8f03ea3200?api_key=vbxctn5sn8x7jz644evkrhtc
## More Examples
##user = client.users.lookup(:screen_name => "gregosuri")
##client.statuses.update.post(:status=>"Ruby Metaprogramming Rocks")
  ## Your code goes here...

