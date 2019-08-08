require "spec"
require "../src/clickhouse"
require "./mock/**"

SERVICE_TIMEOUT = 10
CLICKHOUSE_HOST = ENV["CLICKHOUSE_HOST"]? || "localhost"
CLICKHOUSE_PORT = ENV["CLICKHOUSE_PORT"]?.try(&.to_i32) || 8123

def wait_server_is_up(url : String)
  service = Channel(Bool).new
  timeout = Channel(Bool).new

  spawn do
    loop do
      service.send true if HTTP::Client.get(url).success?
      sleep 1
    end
  end

  spawn do
    sleep SERVICE_TIMEOUT
    timeout.send true
  end

  loop do
    select
    when service.receive
      break
    when timeout.receive
      fail "server is not up (#{host}:#{port}): timeout is #{SERVICE_TIMEOUT}"
    end
  end
end
