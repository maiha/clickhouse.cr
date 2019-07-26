# stdlib
require "csv"
require "http"
require "logger"

# shard
require "var"
require "jq"

class Clickhouse
  alias Type = Bool | Float32 | Float64 | Int16 | Int32 | Int64 | Int8 | String | Time | UInt8 | UInt16 | UInt32 | UInt64
  # See also `Clickhouse::DataType` and `Clickhouse::Cast`
end

require "./clickhouse/*"

class Clickhouse
  var uri             : URI
  var host            : String  = "localhost"
  var port            : Int32   = 8123
  var database        : String  = "default"
  var user            : String  = "default"
  var password        : String
  var profile         : String
  var logger          : Logger  = Logger.new(nil)
  var dns_timeout     : Float64 = 3.0
  var connect_timeout : Float64 = 5.0
  var read_timeout    : Float64 = 60.0

  def initialize(host = nil, port = nil, database = nil, user = nil, password = nil, profile = nil, logger = nil, dns_timeout = nil, connect_timeout = nil, read_timeout = nil)
    self.host            = host
    self.port            = port
    self.database        = database
    self.user            = user
    self.password        = password
    self.profile         = profile
    self.logger          = logger
    self.dns_timeout     = dns_timeout
    self.connect_timeout = connect_timeout
    self.read_timeout    = read_timeout

    self.uri = URI.parse("http://#{self.host}:#{self.port}")
  end

  include Executable
  include Schema::Reflection
end
