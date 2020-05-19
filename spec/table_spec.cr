require "./spec_helper"

describe Clickhouse::Table do
  client = Clickhouse.new(host: CLICKHOUSE_HOST, port: CLICKHOUSE_PORT)

  describe "#count" do
    it "returns UInt64" do
      table = client.table("system", "parts")
      table.count.should be_a(UInt64)
    end
  end

  describe "#inspect" do
    it "works" do
      table = client.table("system", "parts")
      table.inspect.should be_a(String)
    end
  end
end
