require "./spec_helper"

describe Clickhouse do
  client = Clickhouse.new(host: CLICKHOUSE_HOST, port: CLICKHOUSE_PORT)

  describe "#execute" do
    it "works as README" do
      res = client.execute("SELECT 'foo', 2")
      res.to_a                  .should eq([["foo", 2]])
      res.rows                  .should eq(1)
      res.statistics.elapsed    .should be_a(Float64)
      res.statistics.rows_read  .should eq(1)
      res.statistics.bytes_read .should eq(1)
      res.scalar                .should eq("foo")
    end

    it "raises CannotConnectError when it can't connect to server" do
      expect_raises(Clickhouse::CannotConnectError) do
        client = Clickhouse.new(port: 4)
        client.execute("SELECT 1")
      end
    end
  end
end
