require "./spec_helper"

describe Clickhouse::Response do
  client = Clickhouse.new(host: CLICKHOUSE_HOST, port: CLICKHOUSE_PORT)

  it "should be an Enumerable(Array(Type))" do
    res = client.execute("SELECT 1")
    res.should be_a Enumerable(Array(Clickhouse::Type))
  end
end
