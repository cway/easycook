#encoding: utf-8
#require 'rack/protection'
require 'rack/csrf'


configure do
  # = Configuration =
  set :run,             false
  set :show_exceptions, development?
  set :raise_errors,    development?
  set :logging,         true
  set :static,          false # your upstream server should deal with those (nginx, Apache)
  set :views,           File.dirname(__FILE__) + '/views'
  use Rack::Session::Cookie,  :secret => "weitv@2013#ec"
end

configure :production do
end  

# initialize log
require 'logger'
Dir.mkdir('log') unless File.exist?('log')
class ::Logger; alias_method :write, :<<; end
case ENV["RACK_ENV"]
when "production"
  logger = ::Logger.new("log/production.log")
  logger.level = ::Logger::WARN
when "development"
  logger = ::Logger.new(STDOUT)
  logger.level = ::Logger::DEBUG
else
  logger = ::Logger.new("/dev/null")
end
use Rack::CommonLogger, logger

# initialize json
# ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true

# initialize ActiveRecord
ActiveRecord::Base.establish_connection YAML::load(File.open('config/database.yml'))[ENV["RACK_ENV"]]
# ActiveRecord::Base.logger = logger
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
  self.default_timezone = :local
  self.time_zone_aware_attributes = false
  self.logger = logger
  # self.observers = :cacher, :garbage_collector, :forum_observer
end

# load project config
APP_CONFIG = YAML.load_file(File.expand_path("../config", __FILE__) + '/app_config.yml')[ENV["RACK_ENV"]]
# initialize redis cache
# CACHE = ActiveSupport::Cache::DalliStore.new("127.0.0.1")
CACHE = EventMachine::Synchrony::ConnectionPool.new(size: 100) do
  ActiveSupport::Cache.lookup_store :redis_store, { :host => "localhost", :port => "6379", :driver => :synchrony, :expires_in => 1.week }
end
CACHE.logger = logger

# initialize ActiveRecord Cache
SecondLevelCache.configure do |config|
  config.cache_store = CACHE
  config.logger = logger
  config.cache_key_prefix = 'citylife'
end
require File.expand_path("../controllers", __FILE__) + '/application_controller.rb'
# Set autoload directory
%w{models controllers lib exceptions}.each do |dir|
  Dir.glob(File.expand_path("../#{dir}", __FILE__) + '/**/*.rb').each do |file|
    require file
  end
end
